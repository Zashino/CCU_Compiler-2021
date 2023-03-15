grammar myChecker;
options{
	language = Java;
}

@header {
    // import packages here.
    import java.util.HashMap;
}

@members {
    boolean TRACEON = false;
    HashMap<String,Integer> symtab = new HashMap<String,Integer>();

    /*
    attr_type:
      1 => integer,
      2 => float,
      3 => long,
      4 => char,
      5 => void,
      6 => double,
      7 => bool,
      -1 => do not exist,
      -2 => error
      -3 => NULL
     */	   
}

program:VOID_TYPE MAIN '(' ')' '{' declarations statements '}'
        {if (TRACEON) System.out.println("VOID MAIN () {declarations statements}");};

declarations
	: type ID ';' declarations
	{
	   if (TRACEON) System.out.println("declarations: type Identifier : declarations");
	 
  	   if (symtab.containsKey($ID.text)) {
		   System.out.println("Error: " + $ID.getLine() + ": Redeclared identifier.");
	   }
	   else {
		   symtab.put($ID.text, $type.attr_type);	   
	   }
	}
	| { if (TRACEON) System.out.println("declarations: "); }
	;

type returns [int attr_type]
	: INT_TYPE   { if (TRACEON) System.out.println("type: INT"); $attr_type = 1; }
	| FLOAT_TYPE { if (TRACEON) System.out.println("type: FLOAT"); $attr_type = 2; }
	| LONG_TYPE  {if (TRACEON) System.out.println("type: LONG"); $attr_type = 3; }
   	| CHAR_TYPE  {if (TRACEON) System.out.println("type: CHAR"); $attr_type = 4; }
   	| VOID_TYPE  {if (TRACEON) System.out.println("type: VOID"); $attr_type = 5; }
   	| DOUBLE_TYPE {if (TRACEON) System.out.println("type: DOUBLE"); $attr_type = 6; }
   	| BOOL_TYPE  {if (TRACEON) System.out.println("type: VOID"); $attr_type = 7; }
   	;

statements:statement statements
        |;

expr returns [int attr_type]
	: arith_Expr	{ $attr_type = $arith_Expr.attr_type; }
	| TRUE		{ $attr_type = 7; }
	| FALSE	{ $attr_type = 7; }
	;

arith_Expr returns [int attr_type]
	: a = mult_Expr { $attr_type = $a.attr_type; }
        ( '+' b = mult_Expr
		{ if ($a.attr_type != $b.attr_type) {
			  System.out.println("Error: " + $a.start.getLine() + ": Type mismatch for the operator + in an expression.");
		      $attr_type = -2;
		  }
		}
	| '-' c = mult_Expr
	 	{ if ($a.attr_type != $c.attr_type) {
			  System.out.println("Error: " + $a.start.getLine() + ": Type mismatch for the operator - in an expression.");
		      $attr_type = -2;
		  }
		}
	)*
	;

mult_Expr returns [int attr_type]
	: a = sign_Expr { $attr_type = $a.attr_type; }
	( '*' b = sign_Expr
		{ if ($a.attr_type != $b.attr_type) {
			  System.out.println("Error: " + $a.start.getLine() + ": Type mismatch for the operator * in an expression.");
		      $attr_type = -2;
		  }
		}
	| '/' c = sign_Expr
		{ if ($a.attr_type != $c.attr_type) {
			  System.out.println("Error: " + $a.start.getLine() + ": Type mismatch for the operator / in an expression.");
		      $attr_type = -2;
		  }
		}
	)*
	;

sign_Expr returns [int attr_type]
	: atom_Expr { $attr_type = $atom_Expr.attr_type; }
	| '-' atom_Expr { $attr_type = $atom_Expr.attr_type; }
	;
	  
atom_Expr returns [int attr_type]
	: INT_NUM	{ $attr_type = 1; }
	| FLOAT_NUM	{ $attr_type = 2; }
	| LONG_TYPE	{ $attr_type = 3; }
	| DOUBLE_TYPE	{ $attr_type = 6; }
	| '(' arith_Expr ')' { $attr_type = $arith_Expr.attr_type; }
	| ID
	{
	   if (symtab.containsKey($ID.text)) {
	       $attr_type = symtab.get($ID.text);
	   } 
	   else {
	       $attr_type = -1;
	       System.out.println("Error: " + $ID.getLine() + ": ID " + $ID.text + " do not exist.");
	       return $attr_type;
	   }
	}
	;
                   
statement returns [int attr_type]
         : ID '=' expr ';'
         {
	   if (symtab.containsKey($ID.text)) {
	       $attr_type = symtab.get($ID.text);
	   }
	   else {
	       $attr_type = -1;
	       System.out.println("Error: " + $ID.getLine() + ": ID " + $ID.text + " do not exist.");
	       return $attr_type;
	   }
		
	   if ($attr_type != $expr.attr_type) {
           	System.out.println("Error: " + $expr.start.getLine() + ": Type mismatch for the two silde operands in an assignment statement.");
		$attr_type = -2;
          }
	 }
         | IF '(' if_expr  ')' block_statements if_factor
         {
           if ($if_expr.attr_type != 7) {
			  System.out.println("Error: " + $if_expr.start.getLine() + ": The expression type is not boolean.");
		      $attr_type = -2;
	    }
         }
         | PRINTF '(' STRING printf_factor { if (TRACEON) System.out.println("PRINTF FUNCTION"); }
         | FOR '(' for_factor ';' for_expr ';' for_factor2 ')' block_statements
         {
           if ($for_expr.attr_type != 7) {
			  System.out.println("Error: " + $for_expr.start.getLine() + ": The expression type is not boolean.");
		      $attr_type = -2;
	    }
         }
         | WHILE '(' while_expr ')' block_statements
         {
           if ($while_expr.attr_type != 7) {
			  System.out.println("Error: " + $while_expr.start.getLine() + ": The expression type is not boolean.");
		      $attr_type = -2;
	    }
         }
         ;

block_statements:'('statement')' | '{' statements '}';
/*----------if---------*/
if_expr returns [int attr_type]
	: expr if_expr2
	{
	  if (($expr.attr_type!=$if_expr2.attr_type) && ($if_expr2.attr_type!=-3)) {
			  System.out.println("Error: " + $expr.start.getLine() + ": Type mismatch for the expression.");
		      $attr_type = -2;
	  }
	  else{
	  	$attr_type = 7;
	  }
	}
	;
if_expr2 returns [int attr_type]
	: Compare_OP expr { $attr_type = $expr.attr_type; }
	|{ $attr_type = -3; }
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
for_expr returns [int attr_type]
	: expr for_expr2
	{
	  if (($expr.attr_type!=$for_expr2.attr_type) && ($for_expr2.attr_type!=-3)) {
			  System.out.println("Error: " + $expr.start.getLine() + ": Type mismatch for the expression.");
		      $attr_type = -2;
	  }
	  else{
	  	$attr_type = 7;
	  }
	}
	;
for_expr2 returns [int attr_type]
	: Compare_OP expr { $attr_type = $expr.attr_type; }
	|{ $attr_type = -3; }
	;
for_factor2: ID CREASE_OP
	| CREASE_OP ID
	;
/*---------while-------*/
while_expr returns [int attr_type]
	: expr while_expr2
	{
	  if (($expr.attr_type!=$while_expr2.attr_type) && ($while_expr2.attr_type!=-3)) {
			  System.out.println("Error: " + $expr.start.getLine() + ": Type mismatch for the expression.");
		      $attr_type = -2;
	  }
	  else{
	  	$attr_type = 7;
	  }
	}
	;
while_expr2 returns [int attr_type]
	: Compare_OP expr { $attr_type = $expr.attr_type; }
	|{ $attr_type = -3; }
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
BOOL_TYPE : 'bool';

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
