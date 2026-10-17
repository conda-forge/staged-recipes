#include <stdio.h>
#include <webgpu/webgpu.h>

int main(void) {
    WGPUInstance instance = wgpuCreateInstance(NULL);
    if (instance == NULL) {
        fprintf(stderr, "wgpuCreateInstance failed\n");
        return 1;
    }
    wgpuInstanceRelease(instance);
    printf("Created and released a Dawn WGPUInstance\n");
    return 0;
}
