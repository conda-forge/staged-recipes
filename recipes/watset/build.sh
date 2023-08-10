#!/bin/sh

set -eux

mkdir -p "$PREFIX/bin"

mvn -B license:aggregate-third-party-report

mv -fv "target/site/aggregate-third-party-report.html" .

mvn -B -Dshade package

mv -fv "target/watset.jar" "$PREFIX/lib/watset.jar"

cat > "$PREFIX/bin/watset" << WATSET
#!/bin/sh
# shellcheck disable=SC2068
exec java -jar "$PREFIX/lib/watset.jar" \$@
WATSET

chmod +x "$PREFIX/bin/watset"
