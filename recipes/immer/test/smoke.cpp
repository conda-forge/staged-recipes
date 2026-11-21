#include <immer/map.hpp>
#include <immer/vector.hpp>

int main()
{
    const auto empty = immer::vector<int>{};
    const auto first = empty.push_back(13);
    const auto updated = first.set(0, 42);
    if (!empty.empty() || first.size() != 1 || first[0] != 13 || updated[0] != 42)
        return 1;

    const auto original = immer::map<int, int>{}.set(1, 10);
    const auto changed = original.set(1, 20).set(2, 30);
    if (original.size() != 1 || original.at(1) != 10 ||
        changed.size() != 2 || changed.at(1) != 20 || changed.at(2) != 30)
        return 1;
    return 0;
}
