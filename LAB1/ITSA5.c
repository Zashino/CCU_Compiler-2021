#include <stdlib.h>
#include <stdio.h>

int main(){
    int dec;
    scanf("%d",&dec);
    if(dec<0) {
        dec = dec + 256;
    }
    int binary[8] ,pow2;
    for(int i=7;i>=0;i--) {
        pow2 = 1;
        for(int j=0; j<i; j++){
            pow2 = pow2*2;
        }
        binary[i] = dec / pow2;
        dec = dec % pow2;
        printf("%d",binary[i]);
    }
    printf("\n");
}
