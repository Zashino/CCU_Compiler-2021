操作方式:
將antlr-3.5.2-complete-no-st3.jar放在上層目錄
1.指令: make 產生檔案後
將產生 myChecker.token  myCheckerLexer.java myCheckerParser.java 及其他class
2.指令:java -cp ../antlr-3.5.2-complete-no-st3.jar:. myChecker_testParser (測試.c)
可用make clean刪除class檔