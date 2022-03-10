#include <math.h>
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

#include <unistd.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <errno.h>

#ifndef SIZE
#define SIZE (20e6/50e3)
#endif

uint64_t tofixed(double v) {
    v *= (1LL << 46);
    return round(v);
}

void gen(const char *file, double (*func)(double val)) {
    int fd = open(file, O_CREAT | O_WRONLY, S_IRWXU | S_IRWXG | S_IRWXO);
    if(fd == -1) {
        perror("open");
        exit(1);
    }
    printf("%s = {", file);
    for(double i = 0; i < SIZE; i++) {
        double ang = 2 * M_PI * i / SIZE;
        uint64_t val = tofixed(func(ang));
        if(dprintf(fd, "%012llX\n", val) == -1) {
            perror("write");
            exit(1);
        }
        printf("\n\t32'h%012llX", val);
        if(i != SIZE-1) {
            printf(", ");
        }
    }
    printf("\n}\n\n");
    close(fd);
}

int main() {
    char name[32];
    snprintf(name, sizeof(name), "sin%d.hex", (int) SIZE);
    gen(name, sin);

    snprintf(name, sizeof(name), "cos%d.hex", (int) SIZE);
    gen(name, cos);

    return 0;
}
