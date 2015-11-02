%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

//-- Lexer prototype required by bison, aka getNextToken()
int yylex(); 
extern int yylineno;
int yyerror(const char *p) { 
	fprintf(stderr, "Error at line %d\n", yylineno);
	return 1;
}
%}

//-- SYMBOL SEMANTIC VALUES -----------------------------
%union {
  int val; 
  char sym;
  char[128] str;
};
%token <val> num left_bracket right_bracket left_ref right_ref left_parren right_parren colon comma right_tab left_tab
%token <str> file_name idn label 
%type  <val> exp term sfactor factor res

//-- GRAMMAR RULES ---------------------------------------
%%
run: res run | res    /* forces bison to process many stmts */

res: exp STOP         { printf("%d\n", $1); }

exp: exp OPA term     { $$ = ($2 == '+' ? $1 + $3 : $1 - $3); }
| term                { $$ = $1; }

term: term OPM factor { $$ = ($2 == '*' ? $1 * $3 : $1 / $3); }
| sfactor             { $$ = $1; }

sfactor: OPA factor   { $$ = ($1 == '+' ? $2 : -$2); }
| factor              { $$ = $1; }

factor: NUM           { $$ = $1; }
| LP exp RP           { $$ = $2; }

%%
//-- FUNCTION DEFINITIONS ---------------------------------
int main()
{
  yyparse();
  return 0;
}
