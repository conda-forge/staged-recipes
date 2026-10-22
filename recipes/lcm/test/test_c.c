#include <stdio.h>
#include <string.h>
#include <lcm/lcm.h>
#include "exlcm_example_t.h"

static int received = 0;

static void handler(const lcm_recv_buf_t *rbuf, const char *channel,
                    const exlcm_example_t *msg, void *user)
{
    if (msg->timestamp == 42 && msg->num_ranges == 3 && msg->ranges[2] == 7 &&
        strcmp(msg->name, "conda") == 0)
        received = 1;
}

int main(void)
{
    lcm_t *lcm = lcm_create("memq://");
    if (!lcm) {
        fprintf(stderr, "lcm_create failed\n");
        return 1;
    }
    exlcm_example_t_subscribe(lcm, "EXAMPLE", &handler, NULL);

    int16_t ranges[3] = {1, 2, 7};
    exlcm_example_t msg = {0};
    msg.timestamp = 42;
    msg.name = "conda";
    msg.num_ranges = 3;
    msg.ranges = ranges;
    msg.enabled = 1;
    if (exlcm_example_t_publish(lcm, "EXAMPLE", &msg) != 0) {
        fprintf(stderr, "publish failed\n");
        return 1;
    }
    lcm_handle(lcm);
    lcm_destroy(lcm);
    if (!received) {
        fprintf(stderr, "message not received correctly\n");
        return 1;
    }
    printf("C memq round trip OK\n");
    return 0;
}
