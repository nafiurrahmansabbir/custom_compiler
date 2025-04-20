%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex(void);
int yyparse(void);
int yyerror(char *s);
extern FILE *yyin;

typedef enum { TYPE_INT } VarType;

typedef struct {
    char* name;
    VarType type;
    int intValue;
} Symbol;

#define MAX_SYMBOLS 100
Symbol symbolTable[MAX_SYMBOLS];
int symbolCount = 0;

int findSymbolIndex(char* name);
void declareSymbol(char* name, VarType type);
void assignIntValue(char* name, int value);
int getIntValue(char* name);
%}

%union {
    char* str;
    int num;
}

%token <str> IDENTIFIER STRING
%token <num> NUMBER
%token MYTYPE SHOW PRINT IF ELSE WHILE BMI


%token PLUS MINUS TIMES DIVIDE
%token LT GT LE GE EQ NEQ

%token DEG_TO_F FAR_TO_DEG



%left PLUS MINUS
%left TIMES DIVIDE
%left UMINUS

%type <num> expression condition

%%

program:
    statements
    ;

statements:
    statements statement
    | statement
    ;

statement:
      MYTYPE IDENTIFIER ';'        
        { declareSymbol($2, TYPE_INT); }

    | IDENTIFIER '=' expression ';' 
        { assignIntValue($1, $3); }

    | SHOW '(' IDENTIFIER ')' ';'   
        { printf("Value of %s: %d\n", $3, getIntValue($3)); }

    | SHOW '(' expression ')' ';'   
        { printf("Result: %d\n", $3); }

    | PRINT '(' STRING ')' ';'      
        {
            char* txt = strdup($3);
            txt[strlen(txt)-1] = '\0';
            printf("%s\n", txt + 1);
            free(txt);
        }

    | IF '(' condition ')' '{' statements '}' 
        { if ($3) {printf("exicuted"); } }

    | IF '(' condition ')' '{' statements '}' ELSE '{' statements '}' 
        { if ($3) { printf("exicuted"); } else {printf("else exicuted"); } }

    | WHILE '(' condition ')' '{' statements '}' 
    {
        while ($3) {
            // Print to show it's looping
            printf("While loop executed.\n");
            // Just repeat the statements (you can re-define condition or values inside)
        }
    }

    | BMI '(' IDENTIFIER ',' IDENTIFIER ')' ';'
        {
            int h = getIntValue($3);
            int w = getIntValue($5);
            if (h == 0) {
                printf("Error: Height cannot be zero.\n");
            } else {
                float height = h / 100.0;
                float bmi = w / (height * height);
                printf("BMI: %.2f\n", bmi);
                if (bmi < 18.5) {
                    printf("Under BMI\n");
                } else if (bmi < 25.0) {
                    printf("BMI is Good\n");
                } else {
                    printf("Over BMI\n");
                }
            }
        }
    | DEG_TO_F '(' expression ')' ';'
        {
            float celsius = $3;
            float fahrenheit = (celsius * 9.0 / 5.0) + 32;
            printf("Celsius: %.2f -> Fahrenheit: %.2f\n", celsius, fahrenheit);
        }

    | FAR_TO_DEG '(' expression ')' ';'
        {
            float fahrenheit = $3;
            float celsius = (fahrenheit - 32) * 5.0 / 9.0;
            printf("Fahrenheit: %.2f -> Celsius: %.2f\n", fahrenheit, celsius);
        }

    ;

condition:
    expression LT expression     { $$ = $1 < $3; }
    | expression GT expression   { $$ = $1 > $3; }
    | expression LE expression   { $$ = $1 <= $3; }
    | expression GE expression   { $$ = $1 >= $3; }
    | expression EQ expression   { $$ = $1 == $3; }
    | expression NEQ expression  { $$ = $1 != $3; }
    ;

expression:
    expression PLUS expression      { $$ = $1 + $3; }
    | expression MINUS expression   { $$ = $1 - $3; }
    | expression TIMES expression   { $$ = $1 * $3; }
    | expression DIVIDE expression  {
        if ($3 == 0) {
            yyerror("Division by zero");
            $$ = 0;
        } else {
            $$ = $1 / $3;
        }
    }
    | NUMBER                        { $$ = $1; }
    | IDENTIFIER                    { $$ = getIntValue($1); }
    | '(' expression ')'            { $$ = $2; }
    ;

%%

int yyerror(char *s) {
    printf("Error: %s\n", s);
    return 0;
}

int main(int argc, char* argv[]) {
    if (argc > 1) {
        FILE* file = fopen(argv[1], "r");
        if (!file) {
            perror("Failed to open input file");
            return 1;
        }
        yyin = file;
    }
    yyparse();
    return 0;
}

int findSymbolIndex(char* name) {
    for (int i = 0; i < symbolCount; i++) {
        if (strcmp(symbolTable[i].name, name) == 0)
            return i;
    }
    return -1;
}

void declareSymbol(char* name, VarType type) {
    if (findSymbolIndex(name) == -1) {
        symbolTable[symbolCount].name = strdup(name);
        symbolTable[symbolCount].type = type;
        symbolTable[symbolCount].intValue = 0;
        symbolCount++;
    } else {
        printf("Warning: Variable %s already declared.\n", name);
    }
}

void assignIntValue(char* name, int value) {
    int idx = findSymbolIndex(name);
    if (idx != -1 && symbolTable[idx].type == TYPE_INT) {
        symbolTable[idx].intValue = value;
    } else {
        printf("Error: Invalid assignment to %s\n", name);
    }
}

int getIntValue(char* name) {
    int idx = findSymbolIndex(name);
    if (idx != -1 && symbolTable[idx].type == TYPE_INT) {
        return symbolTable[idx].intValue;
    } else {
        printf("Error: Variable %s not found\n", name);
        return 0;
    }
}
