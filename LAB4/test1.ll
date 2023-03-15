; === prologue ====
declare dso_local i32 @printf(i8*, ...)

@str1= private unnamed_addr constant [13 x i8] c"output: %d \0A\00"
@str0= private unnamed_addr constant [13 x i8] c"output: %d \0A\00"
define dso_local i32 @main()
{
%t0 = alloca i32, align 4
%t1 = alloca i32, align 4
store i32 1, i32* %t1
%t2=load i32, i32* %t1
%cond = icmp sgt i32 %t2, 0
br i1 %cond, label %L1, label %L2

L1:
store i32 0, i32* %t0
%t3=load i32, i32* %t0
%t4 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([13 x i8], [13 x i8]* @str0, i64 0, i64 0), i32 %t3)
br label %L3

L2:
%t7=load i32, i32* %t1
%t8 = add nsw i32 %t7, 2
store i32 %t8, i32* %t0
%t9=load i32, i32* %t0
%t10 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([13 x i8], [13 x i8]* @str1, i64 0, i64 0), i32 %t9)
br label %L3

L3:

; === epilogue ===
ret i32 0
}
