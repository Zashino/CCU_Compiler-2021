all:
	java -jar antlr-3.5.2-complete-no-st3.jar subsetC.g
	javac -cp antlr-3.5.2-complete-no-st3.jar subsetC.java
	javac -cp antlr-3.5.2-complete-no-st3.jar:. testLexer.java

clean:
	rm subsetC.java subsetC.tokens
	rm subsetC*.class

