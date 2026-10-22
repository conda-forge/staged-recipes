#include <iostream>
#include <lcm/lcm-cpp.hpp>
#include "exlcm/example_t.hpp"

struct Handler {
    bool received = false;
    void handle(const lcm::ReceiveBuffer *, const std::string &channel,
                const exlcm::example_t *msg)
    {
        received = channel == "EXAMPLE" && msg->timestamp == 42 &&
                   msg->ranges.size() == 3 && msg->ranges[2] == 7 &&
                   msg->name == "conda";
    }
};

int main()
{
    lcm::LCM lcm("memq://");
    if (!lcm.good()) {
        std::cerr << "LCM init failed" << std::endl;
        return 1;
    }
    Handler h;
    lcm.subscribe("EXAMPLE", &Handler::handle, &h);

    exlcm::example_t msg;
    msg.timestamp = 42;
    msg.position[0] = 1.0;
    msg.position[1] = 2.0;
    msg.position[2] = 3.0;
    msg.name = "conda";
    msg.ranges = {1, 2, 7};
    msg.num_ranges = 3;
    msg.enabled = true;
    lcm.publish("EXAMPLE", &msg);
    lcm.handle();
    if (!h.received) {
        std::cerr << "message not received correctly" << std::endl;
        return 1;
    }
    std::cout << "C++ memq round trip OK" << std::endl;
    return 0;
}
