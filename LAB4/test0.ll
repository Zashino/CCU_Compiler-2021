; === prologue ====
declare dso_local i32 @printf(i8*, ...)

@str0= private unnamed_addr constant [12 x i8] c"output: %d\0A\00"
define dso_local i32 @main()
{
%t0 = alloca i32, align 4
%t1 = alloca i32, align 4
store i32 1, i32* %t1
%t2=load i32, i32* %t1
%t3 = add nsw i32 %t2, 2
store i32 %t3, i32* %t0
%t4=load i32, i32* %t0
%cond = icmp eq i32 %t4, 3
br i1 %cond, label %L1, label %L2

L1:
%t5=load i32, i32* %t0
%t6 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([12 x i8], [12 x i8]* @str0, i64 0, i64 0), i32 %t5)
br label %L2

L2:

; === epilogue ===
ret i32 0
}
