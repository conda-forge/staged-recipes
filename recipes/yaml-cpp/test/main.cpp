#include <iostream>
#include <yaml-cpp/yaml.h>

int main()
{
   YAML::Emitter out;
   out << "Hello, World!";

   std::cout << "Here's the output YAML:\n" << out.c_str();

   return 0;
}
