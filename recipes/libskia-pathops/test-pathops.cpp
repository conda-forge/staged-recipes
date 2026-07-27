#include "include/core/SkPathBuilder.h"
#include "include/pathops/SkPathOps.h"

int main() {
    SkPathBuilder builder;
    builder.addRect({0, 0, 6, 6});
    builder.addRect({3, 3, 9, 9});
    std::optional<SkPath> result = Simplify(builder.detach());
    return result && !result->isEmpty() ? 0 : 1;
}
