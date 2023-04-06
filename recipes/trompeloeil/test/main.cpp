#include <trompeloeil.hpp>

class Thing {
public:
  virtual ~Thing() = default;

  virtual void bar(int foo) = 0;
};

struct MockThing : trompeloeil::mock_interface<Thing> {
  IMPLEMENT_MOCK1(bar);
};

int main() {
    MockThing thing;

    {
        REQUIRE_CALL(thing, bar(5));
        thing.bar(5);
    }

    return 0;
}
