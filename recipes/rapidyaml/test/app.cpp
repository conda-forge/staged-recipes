#include <ryml.hpp>

int main(int argc, char const *argv[])
{
    char yml_buf[] = "{foo: 1, bar: [2, 3], john: doe}";

    ryml::Tree tree = ryml::parse_in_place(yml_buf);

    return 0;
}
