實作的功能:
先作宣告
再進行statment
statement可以支援:
	基本算術運算
	if
	if-else
	for-loop
	while-loop
	printf function(支援0到2個參數)


操作方式:
將antlr-3.5.2-complete-no-st3.jar放在上層目錄
1.指令: make 產生檔案後
將產生 myparser.token  myparserLexer.java myparserParser.java 及其他class
2.指令:java -cp ../antlr-3.5.2-complete-no-st3.jar:. testParser (測試.c)
可用make clean刪除class檔