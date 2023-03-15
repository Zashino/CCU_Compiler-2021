grammar myparser;
options{
	language = Java;
}

@members {
    boolean TRACEON = true;
}

program:VOID_TYPE MAIN '(' ')' '{' declarations statements '}'
        {if (TRACEON) System.out.println("VOID MAIN () {declarations statements}");};

declarations:type ID ';' declarations
             { if (TRACEON) System.out.println("declarations: type ID : declarations"); }
           | { if (TRACEON) System.out.println("declarations: ");} ;

type:INT_TYPE { if (TRACEON) System.out.println("type: INT"); }
   |FLOAT_TYPE {if (TRACEON) System.out.println("type: FLOAT"); }
   |LONG_TYPE {if (TRACEON) System.out.println("type: LONG"); }
   |CHAR_TYPE {if (TRACEON) System.out.println("type: CHAR"); }
   |VOID_TYPE {if (TRACEON) System.out.println("type: VOID"); }
   |DOUBLE_TYPE {if (TRACEON) System.out.println("type: DOUBLE"); };

statements:statement statements
        |;

expr: arith_Expr| TRUE | FALSE;

arith_Expr: mult_Expr( '+' mult_Expr | '-' mult_Expr)*;

mult_Expr: sign_Expr( '*' sign_Expr | '/' sign_Expr | '%' sign_Expr)*;

sign_Expr: atom_Expr | '-' atom_Expr;
		  
atom_Expr: INT_NUM
           | FLOAT_NUM
           | ID
           | LONG_TYPE
           | DOUBLE_TYPE
           | '(' arith_Expr ')'
           ;
           
statement: ID '=' expr ';'{ if (TRACEON) System.out.println("ID = Expr"); }
         | IF '(' if_expr  ')' block_statements if_factor
         | PRINTF '(' STRING printf_factor { if (TRACEON) System.out.println("PRINTF FUNCTION"); }
         | FOR '(' for_factor ';' for_factor2 ';' for_factor3 ')' block_statements {if (TRACEON) System.out.println ("FOR (for_expr) {statements}"); }
         | WHILE '(' while_expr ')' block_statements { if (TRACEON) System.out.println("WHILE (while_expr) {statement}"); }
         ;
block_statements:'('statement')' | '{' statements '}';
/*----------if---------*/
if_expr: expr if_expr2
	;
if_expr2: Compare_OP expr
	|
	;
if_factor: ELSE block_statements{if (TRACEON) System.out.println ("IF (if_expr) {statements} ELSE {statements}"); }
	|{if (TRACEON) System.out.println ("IF (expr) {statements}"); }
	;
/*----------for--------*/
for_factor: ID '=' expr
	| INT_TYPE ID '=' expr 
	| LONG_TYPE ID '=' expr 
	| FLOAT_TYPE ID '=' expr 
	| DOUBLE_TYPE ID '=' expr 
	;
for_factor2: expr Compare_OP expr
	;
for_factor3: ID CREASE_OP
	| CREASE_OP ID
	;
/*---------while-------*/
while_expr: expr while_expr2;
while_expr2: Compare_OP expr
	|
	;
/*---------printf------*/
printf_factor: ')' ';'
	| ',' ID ')' ';'
	| ',' ID ',' ID ')' ';'
	;



/* Reservd keywords */
IF : 'if';
DO : 'do';
FOR : 'for';
CASE : 'case';
ELSE : 'else';
BREAK : 'break';
WHILE : 'while';
RETURN : 'return';
STRUCT : 'struct';
SWITCH : 'switch';
TYPEDEF : 'typedef';
CONTINUE : 'continue';

/* STRING, INCLUDE */
STRING : '"' (~('"' | '//'))* '"';

/* Data type */
INT_TYPE : 'int';
LONG_TYPE : 'long';
CHAR_TYPE : 'char';
VOID_TYPE : 'void';
FLOAT_TYPE : 'float';
DOUBLE_TYPE : 'double';

/* Operators */
AND : '&&';
OR : '||' ;

/* Compound Operators */
Compare_OP : '==' | '<=' | '>=' | '!=' | '<' | '>' ;
CREASE_OP : '++' | '--';
RSHIFT_OP : '<<';
LSHIFT_OP : '>>';
TRUE : 'true';
FALSE : 'false';

/* Specail characer */
COMMA : ',';
PERIOD : '.';
ASSIGN : '=';
LOCARION : '&';
POINTER : '*'(LETTER)(LETTER | DIGIT)*;
L_PARENTHESES : '(';
R_PARENTHESES : ')';
L_BRACKET : '[';
R_BRACKET : ']';
L_CURLY_BRACKET : '{';
R_CURLY_BRACKET : '}';
SEMI_COLON : ';';

/* Comments */
COMMENT1 : '//'(.)*'\n' {$channel=HIDDEN;};
COMMENT2 : '/*' (options{greedy=false;}: .)* '*/' {$channel=HIDDEN;};

/* NUM */
INT_NUM : ('0' | ('1'..'9')(DIGIT)*);
FLOAT_NUM: FLOAT1 | FLOAT2 | FLOAT3;

/* FUNCTION */
MAIN : 'main';
PRINTF : 'printf';

ID : (LETTER)(LETTER | DIGIT)*;

fragment FLOAT1 : (DIGIT)+'.'(DIGIT)*;
fragment FLOAT2 : '.'(DIGIT)+;
fragment FLOAT3 : (DIGIT)+;

fragment LETTER : 'a'..'z' | 'A'..'Z' | '_';
fragment DIGIT : '0'..'9';

WS : ( ' ' | '\t' | '\r' | '\n' ) {$channel=HIDDEN;};
