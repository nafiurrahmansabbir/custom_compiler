%{
#include "parser.tab.h"
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
%}

%%

mytype             { return MYTYPE; }
dhoron              { return MYTYPE; }
show                { return SHOW; }
sapau                { return SHOW; }
print               { return PRINT; }
dekhau               { return PRINT; } //add
if                  { return IF; }
jodi                  { return IF; } //
else                { return ELSE; }
nahoi                { return ELSE; } //
while               { return WHILE; }
bmi                 { return BMI; }



degToF      { return DEG_TO_F; }
farToDeg    { return FAR_TO_DEG; }


[0-9]+              { yylval.num = atoi(yytext); return NUMBER; }
[a-zA-Z_][a-zA-Z0-9_]* { yylval.str = strdup(yytext); return IDENTIFIER; }
\"[^\"]*\"          { yylval.str = strdup(yytext); return STRING; }

"=="                { return EQ; }
"!="                { return NEQ; }
"<="                { return LE; }
">="                { return GE; }
"<"                 { return LT; }
">"                 { return GT; }

"+"                 { return PLUS; }
"-"                 { return MINUS; }
"*"                 { return TIMES; }
"/"                 { return DIVIDE; }

"="                 { return '='; }
";"                 { return ';'; }
"("                 { return '('; }
")"                 { return ')'; }
"{"                 { return '{'; }
"}"                 { return '}'; }

[ \t\r\n]+          { /* skip whitespace */ }

.                   { return yytext[0]; }

%%

int yywrap(void) {
    return 1;
}
