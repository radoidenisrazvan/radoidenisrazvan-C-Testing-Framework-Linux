#include <stdio.h>

int divide(int a, int b) {
    if (b == 0) {
        fprintf(stderr, "Error: Division by zero\n");
        return -1;
    }
    return a / b;
}

int main() {
    printf("Hello from file3.c\n");
    printf("10 / 2 = %d\n", divide(10, 2));
    return 0;
}

