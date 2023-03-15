#include <stdlib.h>
#include <stdio.h>
#include <math.h>
int main(){
    int hour1, minute1 ,hour2, minute2;
    scanf("%d %d",&hour1 ,&minute1);
    scanf("%d %d",&hour2 ,&minute2);
    int time;
    time = hour2*60+minute2 - (hour1*60+minute1);

    int time2,money=0;
    if(time>240) {
        time2 = time - 240;
        time = time - time2;
        money = (time2/30)*60;
    }
    if(time>120) {
        time2 = time - 120;
        time = time - time2;
        money = money + (time2/30)*40;
    }
    if(time>0) {
        money = money + (time/30)*30;
    }
    printf("%d\n",money);
}
