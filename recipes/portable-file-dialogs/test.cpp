#include <portable-file-dialogs.h>

int main() {
    // Only check that the API compiles; running would need a desktop session.
    if (false) {
        auto files = pfd::open_file("Open", ".", {"All files", "*"}, pfd::opt::multiselect).result();
        auto file = pfd::save_file("Save", ".", {"All files", "*"}, pfd::opt::none).result();
        auto folder = pfd::select_folder("Folder", ".").result();
        return static_cast<int>(files.size() + file.size() + folder.size());
    }
    return 0;
}
