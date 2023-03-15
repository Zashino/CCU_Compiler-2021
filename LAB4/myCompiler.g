grammar myCompiler;

options {
   language = Java;
}

@header {
    // import packages here.
    import java.util.HashMap;
    import java.util.ArrayList;
}

@members {
    boolean TRACEON = false;

    // Type information.
    public enum Type{
       ERR, BOOL, INT, FLOAT, CHAR, CONST_INT;
    }

    // This structure is used to record the information of a variable or a constant.
    class tVar {
	   int   varIndex; // temporary variable's index. Ex: t1, t2, ..., etc.
	   int   iValue;   // value of constant integer. Ex: 123.
	   float fValue;   // value of constant floating point. Ex: 2.314.
	};

    class Info {
       Type theType;  // type information.
       tVar theVar;
	   
	   Info() {
          theType = Type.ERR;
		  theVar = new tVar();
	   }
    };

	
    // ============================================
    // Create a symbol table.
	// ArrayList is easy to extend to add more info. into symbol table.
	//
	// The structure of symbol table:
	// <variable ID, [Type, [varIndex or iValue, or fValue]]>
	//    - type: the variable type   (please check "enum Type")
	//    - varIndex: the variable's index, ex: t1, t2, ...
	//    - iValue: value of integer constant.
	//    - fValue: value of floating-point constant.
    // ============================================

    HashMap<String, Info> symtab = new HashMap<String, Info>();

    // labelCount is used to represent temporary label.
    // The first index is 0.
    int labelCount = 0;
	
    // varCount is used to represent temporary variables.
    // The first index is 0.
    int varCount = 0;

    int printCount = 0;

    // Record all assembly instructions.
    List<String> TextCode = new ArrayList<String>();


    /*
     * Output prologue.
     */
    void prologue()
    {
       TextCode.add("; === prologue ====");
       TextCode.add("declare dso_local i32 @printf(i8*, ...)\n");
	   TextCode.add("define dso_local i32 @main()");
	   TextCode.add("{");
    }
    
	
    /*
     * Output epilogue.
     */
    void epilogue()
    {
       /* handle epilogue */
       TextCode.add("\n; === epilogue ===");
	   TextCode.add("ret i32 0");
       TextCode.add("}");
    }
    
    
    /* Generate a new label */
    String Ltrue;
    String Lfalse;
    String Lend;
    String newLabel()
    {
       labelCount ++;
       return (new String("L")) + Integer.toString(labelCount);
    } 
    
    
    public List<String> getTextCode()
    {
       return TextCode;
    }
}

program: (VOID_TYPE|INT_TYPE) MAIN '(' (VOID_TYPE)* ')'
        {
           /* Output function prologue */
           prologue();
        }

        '{' 
           declarations
           statements
        '}'
        {
	   if (TRACEON)
	      System.out.println("VOID MAIN () {declarations statements}");

           /* output function epilogue */	  
           epilogue();
        }
        ;


declarations: type Identifier ';' declarations
        {
           if (TRACEON)
              System.out.println("declarations: type Identifier : declarations");

           if (symtab.containsKey($Identifier.text)) {
              // variable re-declared.
              System.out.println("Type Error: " + 
                                  $Identifier.getLine() + 
                                 ": Redeclared identifier.");
              System.exit(0);
           }
                 
           /* Add ID and its info into the symbol table. */
	       Info the_entry = new Info();
		   the_entry.theType = $type.attr_type;
		   the_entry.theVar.varIndex = varCount;
		   varCount ++;
		   symtab.put($Identifier.text, the_entry);

           // issue the instruction.
		   // Ex: \%a = alloca i32, align 4
           if ($type.attr_type == Type.INT) { 
              TextCode.add("\%t" + the_entry.theVar.varIndex + " = alloca i32, align 4");
           }
        }
        | 
        {
           if (TRACEON)
              System.out.println("declarations: ");
        }
        ;


type
returns [Type attr_type]
    : INT_TYPE { if (TRACEON) System.out.println("type: INT"); $attr_type=Type.INT; }
    | CHAR_TYPE { if (TRACEON) System.out.println("type: CHAR"); $attr_type=Type.CHAR; }
    | FLOAT_TYPE {if (TRACEON) System.out.println("type: FLOAT"); $attr_type=Type.FLOAT; }
   	;


statements:statement statements
          |
          ;


statement: assign_stmt ';'
         | if_else_stmt
         | func_no_return_stmt ';'
         | for_stmt
         | return_stmt ';'
         | printf_stmt ';'
         ;

for_stmt: FOR '(' assign_stmt ';'
                  cond_expression ';'
                  assign_stmt
              ')'
                  block_stmt
        ;	 
		 	 
if_else_stmt
            : if_stmt else_stmt
            {
                TextCode.add(Lend + ":");
            }
            ;

	   
if_stmt
            : IF '(' cond_expression ')'
            {
                TextCode.add(Ltrue + ":");
            }
            block_stmt
            ;


else_stmt
            : ELSE
            {
                  Lfalse = Lend;
                  Lend = newLabel();
                  for (int i=TextCode.size()-1; i>0; i--) {
                  	String str = TextCode.get(i);
                  	if(str.contains("\%cond")){
                  	    TextCode.remove(i);
                  	    TextCode.add(i,"br i1 \%cond, label \%" + Ltrue + ", label \%" + Lfalse);
                           break;
                  	}
                  }
                  for (int i=TextCode.size()-1; i>0; i--) {
                  	String str = TextCode.get(i);
                  	if(str.contains("br label")){
                  	    TextCode.remove(i);
                  	    TextCode.add(i,"br label \%" + Lend);
                  	    break;
                  	}
                  }
                  TextCode.add(Lfalse + ":");
            } 
            block_stmt
            |
            ;

				  
block_stmt: '{' statements '}'
          {
              TextCode.add("br label \%" + Lend);
              TextCode.add("");
          }
	  ;

cond_expression
               : a=arith_expression (RelationOP b=arith_expression)*
               {
                   Ltrue = newLabel();
                   Lend = newLabel();
                   if((a.theType == Type.INT) && (b.theType == Type.INT)){
                       switch($RelationOP.text) {
                       case ">":
                               TextCode.add("\%cond = icmp sgt i32 \%t" + a.theVar.varIndex + ", " + b.theVar.varIndex);
                               break;
                       case "<":
                               TextCode.add("\%cond = icmp slt i32 \%t" + a.theVar.varIndex + ", " + b.theVar.varIndex);
                               break;
                       case ">=":
                               TextCode.add("\%cond = icmp sge i32 \%t" + a.theVar.varIndex + ", " + b.theVar.varIndex);
                               break;
                       case "<=":
                               TextCode.add("\%cond = icmp sle i32 \%t" + a.theVar.varIndex + ", " + b.theVar.varIndex);
                               break;
                       case "==":
                               TextCode.add("\%cond = icmp eq i32 \%t" + a.theVar.varIndex + ", " + b.theVar.varIndex);
                               break;
                       case "!=":
                               TextCode.add("\%cond = icmp ne i32 \%t" + a.theVar.varIndex + ", " + b.theVar.varIndex);
                               break;
                           }
                   }
                   else if((a.theType == Type.INT) && (b.theType == Type.CONST_INT)){
                       switch($RelationOP.text) {
                       case ">":
                               TextCode.add("\%cond = icmp sgt i32 \%t" + a.theVar.varIndex + ", " + b.theVar.iValue);
                               break;
                       case "<":
                               TextCode.add("\%cond = icmp slt i32 \%t" + a.theVar.varIndex + ", " + b.theVar.iValue);
                               break;
                       case ">=":
                               TextCode.add("\%cond = icmp sge i32 \%t" + a.theVar.varIndex + ", " + b.theVar.iValue);
                               break;
                       case "<=":
                               TextCode.add("\%cond = icmp sle i32 \%t" + a.theVar.varIndex + ", " + b.theVar.iValue);
                               break;
                       case "==":
                               TextCode.add("\%cond = icmp eq i32 \%t" + a.theVar.varIndex + ", " + b.theVar.iValue);
                               break;
                       case "!=":
                               TextCode.add("\%cond = icmp ne i32 \%t" + a.theVar.varIndex + ", " + b.theVar.iValue);
                               break;
                           }
                   }
                   else if((a.theType == Type.CONST_INT) && (b.theType == Type.CONST_INT)){
                       switch($RelationOP.text) {
                       case ">":
                               TextCode.add("\%cond = icmp sgt i32 \%t" + a.theVar.iValue + ", " + b.theVar.iValue);
                               break;
                       case "<":
                               TextCode.add("\%cond = icmp slt i32 \%t" + a.theVar.iValue + ", " + b.theVar.iValue);
                               break;
                       case ">=":
                               TextCode.add("\%cond = icmp sge i32 \%t" + a.theVar.iValue + ", " + b.theVar.iValue);
                               break;
                       case "<=":
                               TextCode.add("\%cond = icmp sle i32 \%t" + a.theVar.iValue + ", " + b.theVar.iValue);
                               break;
                       case "==":
                               TextCode.add("\%cond = icmp eq i32 \%t" + a.theVar.iValue + ", " + b.theVar.iValue);
                               break;
                       case "!=":
                               TextCode.add("\%cond = icmp ne i32 \%t" + a.theVar.iValue + ", " + b.theVar.iValue);
                               break;
                           }
                   }
                   TextCode.add("br i1 \%cond, label \%" + Ltrue + ", label \%" + Lend);
                   TextCode.add(""); 
               }
               ;

printf_stmt: PRINTF '(' STRING_LITERAL 
          ( ')'
              {
              String temp = $STRING_LITERAL.text;
              int len = temp.length() - 2;
              temp = temp.replace("\\n", "\\0A\\00");
              TextCode.add(2,"@str" + printCount +"= private unnamed_addr constant [" + len + " x i8] c" + temp );
              TextCode.add("\%t" + varCount + " = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([" + len + " x i8], [" + len + " x i8]* @str" + printCount +", i64 0, i64 0))" );
              printCount ++;
              varCount ++;       
              }
           | ',' a=Identifier ')'
              {
              String temp = $STRING_LITERAL.text;
              int len = temp.length() - 2;
              temp = temp.replace("\\n", "\\0A\\00");
              TextCode.add(2,"@str" + printCount +"= private unnamed_addr constant [" + len + " x i8] c" + temp );
              TextCode.add("\%t" + varCount + "=load i32, i32* \%t" + symtab.get($a.text).theVar.varIndex);
              int id1 = varCount;
              varCount ++;       
              TextCode.add("\%t" + varCount++ + " = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([" + len + " x i8], [" + len + " x i8]* @str" + printCount +", i64 0, i64 0), i32 \%t" + id1 + ")" );
              printCount ++;
              varCount ++;
              varCount ++;
              }
           | ',' b=Identifier ',' c=Identifier ')'
              {
              String temp = $STRING_LITERAL.text;
              int len = temp.length() - 2;
              temp = temp.replace("\\n", "\\0A\\00");
              TextCode.add(2,"@str" + printCount +"= private unnamed_addr constant [" + len + " x i8] c" + temp );
              TextCode.add("\%t" + varCount + "=load i32, i32* \%t" + symtab.get($b.text).theVar.varIndex);
              int id1 = varCount;
              varCount ++;   
              TextCode.add("\%t" + varCount + "=load i32, i32* \%t" + symtab.get($c.text).theVar.varIndex);
              int id2 = varCount;
              varCount ++;    
              TextCode.add("\%t" + varCount++ + " = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([" + len + " x i8], [" + len + " x i8]* @str" + printCount +", i64 0, i64 0), i32 \%t" + id1 + ", i32 \%t" + id2 + ")" );
              printCount ++;
              varCount ++;
              varCount ++;
              }
          )
          ;

return_stmt: RETURN Integer_constant
	  ;

assign_stmt: Identifier '=' arith_expression
             {
                Info theRHS = $arith_expression.theInfo;
				Info theLHS = symtab.get($Identifier.text); 
		   
                if ((theLHS.theType == Type.INT) &&
                    (theRHS.theType == Type.INT)) {		   
                   // issue store insruction.
                   // Ex: store i32 \%tx, i32* \%ty
                   TextCode.add("store i32 \%t" + theRHS.theVar.varIndex + ", i32* \%t" + theLHS.theVar.varIndex);
				} else if ((theLHS.theType == Type.INT) &&
				    (theRHS.theType == Type.CONST_INT)) {
                   // issue store insruction.
                   // Ex: store i32 value, i32* \%ty
                   TextCode.add("store i32 " + theRHS.theVar.iValue + ", i32* \%t" + theLHS.theVar.varIndex);				
				}
			 }
             ;

		   
func_no_return_stmt: Identifier '(' argument ')'
                   ;


argument: arg (',' arg)*
        ;

arg: arith_expression
   | STRING_LITERAL
   ;
			   
arith_expression
returns [Info theInfo]
@init {theInfo = new Info();}
                : a=multExpr { $theInfo=$a.theInfo; }
                 ( '+' b=multExpr
                    {
                       // We need to do type checking first.
                       // ...
                         
                       // code generation.
					   
                       if (($a.theInfo.theType == Type.INT) &&
                           ($b.theInfo.theType == Type.INT)) {
                           TextCode.add("\%t" + varCount + " = add nsw i32 \%t" + $a.theInfo.theVar.varIndex + ", \%t" + $b.theInfo.theVar.varIndex);

					       // Update arith_expression's theInfo.
					       $theInfo.theType = Type.INT;
					       $theInfo.theVar.varIndex = varCount;
					       varCount ++;
                       } else if (($a.theInfo.theType == Type.INT) &&
					       ($b.theInfo.theType == Type.CONST_INT)) {
                           TextCode.add("\%t" + varCount + " = add nsw i32 \%t" + $a.theInfo.theVar.varIndex + ", " + $b.theInfo.theVar.iValue);
		   
					       // Update arith_expression's theInfo.
					       $theInfo.theType = Type.INT;
					       $theInfo.theVar.varIndex = varCount;
					       varCount ++;
                       } else if (($a.theInfo.theType == Type.CONST_INT) &&
					       ($b.theInfo.theType == Type.CONST_INT)) {
                           TextCode.add("\%t" + varCount + " = add nsw i32 " + $a.theInfo.theVar.iValue + ", " + $b.theInfo.theVar.iValue);
	   
					       // Update arith_expression's theInfo.
					       $theInfo.theType = Type.INT;
					       $theInfo.theVar.varIndex = varCount;
					       varCount ++;
                       }
                    }
                 | '-' c=multExpr
                    {
                       if (($a.theInfo.theType == Type.INT) &&
                           ($c.theInfo.theType == Type.INT)) {
                           TextCode.add("\%t" + varCount + " = sub nsw i32 \%t" + $a.theInfo.theVar.varIndex + ", \%t" + $c.theInfo.theVar.varIndex);
					   
					       // Update arith_expression's theInfo.
					       $theInfo.theType = Type.INT;
					       $theInfo.theVar.varIndex = varCount;
					       varCount ++;
                       } else if (($a.theInfo.theType == Type.INT) &&
					       ($c.theInfo.theType == Type.CONST_INT)) {
                           TextCode.add("\%t" + varCount + " = sub nsw i32 \%t" + $a.theInfo.theVar.varIndex + ", " + $c.theInfo.theVar.iValue);
					   
					       // Update arith_expression's theInfo.
					       $theInfo.theType = Type.INT;
					       $theInfo.theVar.varIndex = varCount;
					       varCount ++;
                       } else if (($a.theInfo.theType == Type.CONST_INT) &&
					       ($c.theInfo.theType == Type.CONST_INT)) {
                           TextCode.add("\%t" + varCount + " = sub nsw i32 " + $a.theInfo.theVar.iValue+ ", " + $c.theInfo.theVar.iValue);
					   
					       // Update arith_expression's theInfo.
					       $theInfo.theType = Type.INT;
					       $theInfo.theVar.varIndex = varCount;
					       varCount ++;
                       }
                    }
                 )*
                 ;

multExpr
returns [Info theInfo]
@init {theInfo = new Info();}
          : a=signExpr { $theInfo=$a.theInfo; }
          ( '*' b=signExpr
             {
                       if (($a.theInfo.theType == Type.INT) &&
                           ($b.theInfo.theType == Type.INT)) {
                           TextCode.add("\%t" + varCount + " = mul nsw i32 \%t" + $a.theInfo.theVar.varIndex + ", \%t" + $b.theInfo.theVar.varIndex);
					   
					       // Update arith_expression's theInfo.
					       $theInfo.theType = Type.INT;
					       $theInfo.theVar.varIndex = varCount;
					       varCount ++;
                       } else if (($a.theInfo.theType == Type.INT) &&
					       ($b.theInfo.theType == Type.CONST_INT)) {
                           TextCode.add("\%t" + varCount + " = mul nsw i32 \%t" + $a.theInfo.theVar.varIndex + ", " + $b.theInfo.theVar.iValue);
					   
					       // Update arith_expression's theInfo.
					       $theInfo.theType = Type.INT;
					       $theInfo.theVar.varIndex = varCount;
					       varCount ++;
                       } else if (($a.theInfo.theType == Type.CONST_INT) &&
					       ($b.theInfo.theType == Type.CONST_INT)) {
                           TextCode.add("\%t" + varCount + " = mul nsw i32 " + $a.theInfo.theVar.iValue + ", " + $b.theInfo.theVar.iValue);
					   
					       // Update arith_expression's theInfo.
					       $theInfo.theType = Type.INT;
					       $theInfo.theVar.varIndex = varCount;
					       varCount ++;
                       }
             }
          | '/' c=signExpr
             {
                       if (($a.theInfo.theType == Type.INT) &&
                           ($c.theInfo.theType == Type.INT)) {
                           TextCode.add("\%t" + varCount + " = div nsw i32 \%t" + $a.theInfo.theVar.varIndex + ", \%t" + $c.theInfo.theVar.varIndex);
					   
					       // Update arith_expression's theInfo.
					       $theInfo.theType = Type.INT;
					       $theInfo.theVar.varIndex = varCount;
					       varCount ++;
                       } else if (($a.theInfo.theType == Type.INT) &&
					       ($c.theInfo.theType == Type.CONST_INT)) {
                           TextCode.add("\%t" + varCount + " = div nsw i32 \%t" + $a.theInfo.theVar.varIndex + ", " + $c.theInfo.theVar.iValue);
					   
					       // Update arith_expression's theInfo.
					       $theInfo.theType = Type.INT;
					       $theInfo.theVar.varIndex = varCount;
					       varCount ++;
                       } else if (($a.theInfo.theType == Type.CONST_INT) &&
					       ($c.theInfo.theType == Type.CONST_INT)) {
                           TextCode.add("\%t" + varCount + " = div nsw i32 " + $a.theInfo.theVar.iValue + ", " + $c.theInfo.theVar.iValue);
					   
					       // Update arith_expression's theInfo.
					       $theInfo.theType = Type.INT;
					       $theInfo.theVar.varIndex = varCount;
					       varCount ++;
                       }
              }
	  )*
	  ;

signExpr
returns [Info theInfo]
@init {theInfo = new Info();}
        : primaryExpr { $theInfo=$primaryExpr.theInfo; } 
        | '-' primaryExpr
           {
                       if ($primaryExpr.theInfo.theType == Type.INT) {
                           TextCode.add("\%t" + varCount + " = sub nsw i32 0, \%t" + $primaryExpr.theInfo.theVar.varIndex);
					   
					       // Update arith_expression's theInfo.
					       $theInfo.theType = Type.INT;
					       $theInfo.theVar.varIndex = varCount;
					       varCount ++;
					       }
           }
	;
		  
primaryExpr
returns [Info theInfo]
@init {theInfo = new Info();}
           : Integer_constant
	     {
            $theInfo.theType = Type.CONST_INT;
			$theInfo.theVar.iValue = Integer.parseInt($Integer_constant.text);
         }
           | Floating_point_constant
           | Identifier
              {
                // get type information from symtab.
                Type the_type = symtab.get($Identifier.text).theType;
				$theInfo.theType = the_type;

                // get variable index from symtab.
                int vIndex = symtab.get($Identifier.text).theVar.varIndex;
				
                switch (the_type) {
                case INT: 
                         // get a new temporary variable and
						 // load the variable into the temporary variable.
                         
						 // Ex: \%tx = load i32, i32* \%ty.
						 TextCode.add("\%t" + varCount + "=load i32, i32* \%t" + vIndex);
				         
						 // Now, Identifier's value is at the temporary variable \%t[varCount].
						 // Therefore, update it.
						 $theInfo.theVar.varIndex = varCount;
						 varCount ++;
                         break;
                case FLOAT:
                         break;
                case CHAR:
                         break;
			
                }
              }
	   | '&' Identifier
	   | '(' arith_expression ')'
	   {
	       $theInfo.theType = $arith_expression.theInfo.theType;
	       $theInfo.theVar.varIndex = $arith_expression.theInfo.theVar.varIndex;
	       $theInfo.theVar.iValue = $arith_expression.theInfo.theVar.iValue;
	   }
           ;

		   
/* description of the tokens */
/* Data type */
INT_TYPE : 'int';
CHAR_TYPE : 'char';
VOID_TYPE : 'void';
FLOAT_TYPE : 'float';
BOOL_TYPE : 'bool';

MAIN: 'main';
IF: 'if';
ELSE: 'else';
FOR: 'for';
PRINTF: 'printf';
RETURN: 'return';

RelationOP: '>' |'>=' | '<' | '<=' | '==' | '!=';

Identifier:('a'..'z'|'A'..'Z'|'_') ('a'..'z'|'A'..'Z'|'0'..'9'|'_')*;
Integer_constant:'-'*('0'..'9'+);
Floating_point_constant:'0'..'9'+ '.' '0'..'9'+;

STRING_LITERAL
    :  '"' ( EscapeSequence | ~('\\'|'"') )* '"'
    ;

WS:( ' ' | '\t' | '\r' | '\n' ) {$channel=HIDDEN;};
COMMENT:'/*' .* '*/' {$channel=HIDDEN;};


fragment
EscapeSequence
    :   '\\' ('b'|'t'|'n'|'f'|'r'|'\"'|'\''|'\\')
    ;
