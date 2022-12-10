#include <QMimeDatabase>

int main() {
    QMimeDatabase db;
    return (db.allMimeTypes().size() > 0)? 0: 1;
}