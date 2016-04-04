/*
 * Unit test for compound literal C99-to-C89 replacement.
 */

typedef struct AVRational { int num, den; } AVRational;
struct AVRational2 { int num; int den; char **test[3]; };
typedef struct AVRational2 AVRational2;
typedef struct AVRational4 AVRational4;
typedef struct { int num, den; struct AVRational test; } AVRational3;

static AVRational  gap_test() {
    AVRational gap = { .den = 4 };
    gap.num = 1;
    return gap;
}

static AVRational call_function_2(AVRational x)
{
    AVRational y = (struct AVRational) { x.den, x.num };
    int z = -1; // unused
    y = (AVRational) { y.den, y.num };
    if (z == 0)
        return (AVRational) { 5, -5 };
    else
        return x.num > 0 ? (AVRational) { x.num, x.den } :
               x.den > 0 ? (AVRational) { x.den, x.num } :
                           (AVRational) { 0, 0 };
}

static int call_function_3(AVRational x)
{
    return x.num ^ x.den;
}

static int call_function(AVRational x)
{
    AVRational y = x.num > 0 ? call_function_2((AVRational) { x.num, x.den }) :
                   x.den > 0 ? call_function_2((AVRational) { x.den, x.num }) :
                               call_function_2((AVRational) { 0, 0 });
    int res;

    if ((res = call_function_3((AVRational) { 5, -5 }) > 0)) {
        return ((AVRational) { -8, 8 }).den;
    } else if (1 && (res = call_function_3((AVRational) { 6, -6 }) > 0)) {
        return call_function_3((AVRational) { -5, 5 });
    } else
        return 0;
}

#define lut_vals(x) x, x+1, x+2, x+3
#define lut(x) { lut_vals(x), lut_vals(x+4) }
static const int l[][8] = {
    lut(0),
    lut(16),
    lut(32),
    lut(48)
};

typedef struct AVCodec {
    int (*decode) (AVRational x);
    const int *samplefmts;
} AVCodec;

static AVCodec decoder = {
    .samplefmts = (const int[]) { 0, 1 },
    .decode = call_function,
};

typedef struct AVFilterPad {
    const char *name;
} AVFilterPad;

typedef struct AVFilter {
    const char *name;
    const AVFilterPad *inputs;
} AVFilter;

AVFilter filter = {
    .name = "filter",
    .inputs = (const AVFilterPad[]) {{.name="pad",},{.name=(void*)0,},},
};

int main(int argc, char *argv[])
{
    int var;

#define X 3
    switch (call_function((AVRational){1, 1})) {
    case 0:
        call_function((AVRational){2, 2});
        break;
    default:
        call_function((AVRational){3, 3});
        break;
    }
    var = ((const int[2]){1,2})[argc];
    var = call_function((AVRational){1, 2});
    if (var == 0) return call_function((AVRational){X, 2});
    else          return call_function((AVRational){2, X});
#undef X
}