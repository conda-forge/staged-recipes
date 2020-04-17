package main
/* 
    #include <stdio.h>

    void test(const char* str)
    {
        printf(str);
	printf("\n");
    }
*/
import "C"

func main() {
    C.test(C.CString("Testing!!!"))
}
