/* Link-time smoke test. Mirrors how weston's VNC backend consumes PAM
 * (pam_appl.h + pam_misc.h). The binary is only linked and inspected,
 * never executed: at runtime the real system libpam.so.0 would be used. */
#include <security/pam_appl.h>
#include <security/pam_misc.h>
#include <security/pam_modules.h>

int main(void)
{
    pam_handle_t *pamh = 0;
    struct pam_conv conv = {0, 0};
    int ret = pam_start("pam-stubs-test", "user", &conv, &pamh);
    if (ret == PAM_SUCCESS) {
        pam_authenticate(pamh, 0);
        pam_end(pamh, ret);
    }
    return ret;
}
