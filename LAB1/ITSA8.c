#include <stdio.h>
#include <stdlib.h>
int is_prime(int);
int main(int argc, char *argv[])
{
	int num;
	scanf("%d",&num);
	int i;
	if(num ==1 )
		printf("YES\n");
    for(i=2;i<num;i++){
        if(num%i==0){
            printf("NO\n");
            return 0;
        }
    }
    printf("YES\n");
}

