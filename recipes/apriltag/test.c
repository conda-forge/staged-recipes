#include <apriltag.h>
#include <tag36h11.h>
#include <common/pjpeg.h>

int
main(int argc, char *argv[])
{
    apriltag_detector_t *td = apriltag_detector_create();
    apriltag_family_t *tf = tag36h11_create();
    apriltag_detector_add_family(td, tf);

    apriltag_detector_destroy(td);
    tag36h11_destroy(tf);

    return EXIT_SUCCESS;
}
