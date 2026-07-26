#include <stdlib.h>
#include <unity.h>


void setUp (){
};
void tearDown(){
};
void test_unity(){
    int i = 2;
    int a = 2;

    TEST_ASSERT_EQUAL(a,i);
}
int main () {
    UNITY_BEGIN();

    RUN_TEST(test_unity);

    return UNITY_END();
}