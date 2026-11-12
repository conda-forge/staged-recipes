#include <ghostty/vt.h>
int main(void) {
    GhosttyOscParser parser;
    if (ghostty_osc_new(NULL, &parser) != GHOSTTY_SUCCESS) return 1;
    ghostty_osc_free(parser);
    return 0;
}
