%{
   #include "expr_parser.hh"
   void yyerror(char *s);
%}

%option yylineno
%option noyywrap

%x STR

%%

==              return EQ;
[<]=            return LE;
>=              return GE;
!=              return NE;
[0-9]+          { yylval.NUM = atoi(yytext);
                  return NUM;
                }
\$[a-zA-Z_][a-zA-Z0-9_]* { yylval.ID = yytext;
                  return ID;
                }
[ \t\r\n]       ; // whitespace
[-()=<>+*/!%] { return *yytext; }
.               yyerror("Invalid character");

%%

void set_input_string(const char* in) {
  yy_scan_string(in);
}

void end_lexical_scan(void) {
  yy_delete_buffer(YY_CURRENT_BUFFER);
}
