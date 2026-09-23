// Exercises the public headers and the two things consumers most need from this
// build: that path operations are actually linked into the library, and that
// SK_API resolves correctly against the shared library.
#include "include/core/SkPath.h"
#include "include/core/SkPathBuilder.h"
#include "include/core/SkRect.h"
#include "include/pathops/SkPathOps.h"

#include <cstdio>

int main() {
    SkPath a = SkPathBuilder().addRect(SkRect::MakeLTRB(0, 0, 10, 10)).detach();
    SkPath b = SkPathBuilder().addRect(SkRect::MakeLTRB(5, 5, 15, 15)).detach();

    std::optional<SkPath> united = Op(a, b, kUnion_SkPathOp);
    if (!united.has_value() || united->isEmpty()) {
        std::fprintf(stderr, "union of two overlapping rects failed\n");
        return 1;
    }

    std::optional<SkPath> simplified = Simplify(*united);
    if (!simplified.has_value()) {
        std::fprintf(stderr, "Simplify failed\n");
        return 1;
    }

    std::printf("ok: %d verbs after union\n", united->countVerbs());
    return 0;
}
