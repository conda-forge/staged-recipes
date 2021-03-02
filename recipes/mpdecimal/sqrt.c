#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <mpdecimal.h>

int
main(void)
{
    mpd_context_t ctx;
    mpd_t *a;
    mpd_t *result;
    char *rstring;
    char status_str[MPD_MAX_FLAG_STRING];
    int ret = 0;

    mpd_init(&ctx, 38);
    ctx.traps = 0;

    result = mpd_new(&ctx);
    a = mpd_new(&ctx);
    mpd_set_string(a, "1844674407370955161500000000100000000001", &ctx);

    mpd_sqrt(result, a, &ctx);
    rstring = mpd_to_sci(result, 1);
    mpd_snprint_flags(status_str, MPD_MAX_FLAG_STRING, ctx.status);

    if (strcmp(rstring, "42949672959999999998.835846782894805074") != 0 ||
        strcmp(status_str, "Inexact Rounded") != 0) {
        ret = 1;
    }

    mpd_del(a);
    mpd_del(result);
    mpd_free(rstring);

    return ret;
}
