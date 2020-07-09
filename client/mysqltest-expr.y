%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>

    /* Declarations */
    void set_input_string(const char* in);
    void end_lexical_scan(void);
    extern int yylineno;
    extern int yylex();

    void yyerror(char *s) {
      fprintf(stderr, "%s, line %d\n", s, yylineno);
      exit(1);
    }

    enum expr_op {
      EQ_OP,
      NE_OP,
      GT_OP,
      GE_OP,
      LT_OP,
      LE_OP,
      PLUS_OP,
      MINUS_OP,
      DIV_OP,
      MOD_OP,
      MUL_OP,
      UNARY_MINUS_OP,
      UNARY_NOT_OP,
      ILLEG_OP,
    };

    enum var_node_type {
    	BINARY_NODE,
    	UNARY_NODE,
    	NUM_NODE,
    	ID_NODE,
    	ILLEG_NODE,
    };

    typedef struct var_node{
    	enum var_node_type type;
    	struct var_node* left;
    	enum expr_op op_type;
    	struct var_node* right;
    	int value;
    	char* var_name;
    }var_node;

    var_node* node_stack[100];
    int stack_size = 0;

    void push_node(var_node* node){
      node_stack[stack_size++] = node;
    }

    var_node* pop_node(){
      var_node* buf = node_stack[--stack_size];
      return buf;
    }

    void create_num_node(int num){
      var_node* buf = (var_node*) malloc(sizeof(var_node));
      buf->type = NUM_NODE;
      buf->value = num;
      push_node(buf);
    }

    void create_unary_node(enum expr_op op){
        var_node* buf = (var_node*) malloc(sizeof(var_node));
        buf->type = UNARY_NODE;
        buf->op_type = op;
        buf->left = pop_node();
        push_node(buf);
    }

    void create_id_node(const char* name){
	var_node* buf = (var_node*) malloc(sizeof(var_node));
	buf->type = ID_NODE;
	int len = strlen(name);
	buf->var_name = (char*) malloc(len);
	strncpy(buf->var_name, name, len);
	push_node(buf);
    }

    void create_binary_node(enum expr_op op){
    	var_node* buf = (var_node*) malloc(sizeof(var_node));
    	buf->type = BINARY_NODE;
	buf->op_type = op;
	buf->right = pop_node();
	buf->left = pop_node();
	push_node(buf);
    }

    void create_illegal_node(){
    	var_node* buf = (var_node*) malloc(sizeof(var_node));
	buf->type = ILLEG_NODE;
	push_node(buf);
    }

%}

%define api.value.type union

%token EQ LE GE NE
%token <int> NUM
%token <char const *> ID

%%

EXPR:   EXPR1		{}
|       EXPR EQ EXPR1	{create_binary_node(EQ_OP);}
|       EXPR LE EXPR1	{create_binary_node(LE_OP);}
|       EXPR GE EXPR1	{create_binary_node(GE_OP);}
|       EXPR NE EXPR1	{create_binary_node(NE_OP);}
|       EXPR '>' EXPR1	{create_binary_node(GT_OP);}
|       EXPR '<' EXPR1	{create_binary_node(LT_OP);}
;

EXPR1:  TERM		{}
|       EXPR1 '+' TERM	{create_binary_node(PLUS_OP);}
|       EXPR1 '-' TERM	{create_binary_node(MINUS_OP);}
;

TERM:   VAL		{}
|       TERM '*' VAL    {create_binary_node(MUL_OP);}
|       TERM '/' VAL    {create_binary_node(DIV_OP);}
|       TERM '%' VAL    {create_binary_node(MOD_OP);}
;


VAL:    NUM		{create_num_node($1);}
|       '-' VAL		{create_unary_node(UNARY_MINUS_OP);}
|       '!' VAL		{create_unary_node(UNARY_NOT_OP);}
|       '(' EXPR ')'    {}
|       ID		{create_id_node($1);}
;

%%

/* This function parses a string */
var_node* parse_expr(const char* in) {
  set_input_string(in);
  int rv = yyparse();
  end_lexical_scan();
  return node_stack[0];
}

