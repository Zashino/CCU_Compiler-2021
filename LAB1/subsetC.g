lexer grammar subsetC;
options{
	language = Java;
}

/* Reservd keywords */
IF : 'if';
DO : 'do';
FOR : 'for';
CASE : 'case';
BREAK : 'break';
WHILE : 'while';
RETURN : 'return';
STRUCT : 'struct';
SWITCH : 'switch';
TYPEDEF : 'typedef';
CONTINUE : 'continue';

/* STRING, INCLUDE */
STRING : '"' (~('"' | '//'))* '"';
INCLUDE : '#include';
LIBRARY : '<' (LETTER | DIGIT | '.')* '>';

/* Data type */
INT_TYPE : 'int';
LONG_TYPE : 'long';
CHAR_TYPE : 'char';
VOID_TYPE : 'void';
FLOAT_TYPE : 'float';
DOUBLE_TYPE : 'double';
INT_FORMAT : '%d';
CHAR_FORMAT : '%c';
STRING_FORMAT : '%s';
FLOAT_FORMAT : '%f';
DOUBLE_FORMAT : '%ld';

/* Operators */
ADD : '+';
SUB : '-';
MUL : '*';
DIV : '/';
MOD : '%';
AND : '&&';
OR : '||' ;

/* Compound Operators */
EQ_OP : '==';
LE_OP : '<=';
GE_OP : '>=';
NE_OP : '!=';
PP_OP : '++';
MM_OP : '--';
LESS : '<';
GREATER : '>';
RSHIFT_OP : '<<';
LSHIFT_OP : '>>';

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
COMMENT1 : '//'(.)*'\n';
COMMENT2 : '/*' (options{greedy=false;}: .)* '*/';

/* NUM */
DEC_NUM : ('0' | ('1'..'9')(DIGIT)*);
FLOAT_NUM: FLOAT1 | FLOAT2 | FLOAT3;

ID : (LETTER)(LETTER | DIGIT)*;

fragment FLOAT1 : (DIGIT)+'.'(DIGIT)*;
fragment FLOAT2 : '.'(DIGIT)+;
fragment FLOAT3 : (DIGIT)+;

fragment LETTER : 'a'..'z' | 'A'..'Z' | '_';
fragment DIGIT : '0'..'9';

NEW_LINE : '\n';
WS : (' ' | '\t' | '\r');
