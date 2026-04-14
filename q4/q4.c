#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include <dlfcn.h>

int main(){
    char s[7];
    int a;
    int b;
    char prev_s[7] = "";
    void *handle = NULL;

    while(scanf("%s", s) == 1  ){
        scanf("%d", &a);
        scanf("%d", &b);

        char lib[16];
        
        sprintf(lib, "./lib%s.so", s);

        if(strcmp(s, prev_s) != 0){
            if(handle) dlclose(handle);
            handle = dlopen(lib, RTLD_LAZY);
            strcpy(prev_s, s);
        }

        int (*op)(int, int);
        *(void **)(&op) = dlsym(handle, s);

        int ans = op(a, b);
        printf("%d\n", ans);
    }

    if(handle) dlclose(handle);

    return 0;
}