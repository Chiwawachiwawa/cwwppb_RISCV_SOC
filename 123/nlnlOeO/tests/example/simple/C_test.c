#include<stdio.h>
#include"..\lib\utils.h"
int main(){
    int arr[]={20,1,0,2,1,16,1,3,2,1,2,17}; 
    int height=12;
    int ans=trap(arr,height);
    if (ans == 141)
        set_test_pass();
    else
        set_test_fail();

    return 0;
    /*printf("%d\n",ans);*/
}
int trap(int* height, int heightSize){
    int maxh=0,maxhi;
    if(heightSize==0||heightSize==1)
        return 0;
    for(int i=0;i<heightSize;i++){
        if(height[i]>maxh){
            maxh=height[i];
            maxhi=i;
        }
    }
    int water_l=0;
    int rain=0;
    for(int i=0;i<maxhi;i++){
        if(height[i]>water_l){
            water_l=height[i];
        }
        rain+=water_l-height[i];
    }
    water_l=0;
    for(int i=heightSize-1;i>maxhi;i--){
        if(height[i]>water_l){
            water_l=height[i];
        }
        rain+=water_l-height[i];
    }
    return rain;
}