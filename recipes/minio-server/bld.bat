:: setup
echo Setup Environment Variables
set CGO_ENABLED=0
set MINIO_RELEASE=RELEASE
for /f %%i in ('go env GOPATH') do set GOPATH=%%i
for /f %%i in ('go run buildscripts\gen-ldflags.go "%GIT_TIME%"') do set LDFLAGS=%%i
if %errorlevel% neq 0 exit /b %errorlevel%

:: build
echo Build MinIO Server
go build -tags kqueue -trimpath --ldflags "%LDFLAGS%" -o "%PREFIX%\minio.exe"
if %errorlevel% neq 0 exit /b %errorlevel%

:: collect licenses
:: see manual_licenses for licenses that are not automatically detected
echo Collect Licenses
go-licenses save . ^
    --save_path=%SRC_DIR%\library_licenses\ ^
    --ignore github.com/cespare/xxhash/v2 ^
    --ignore github.com/dchest/siphash ^
    --ignore github.com/golang/snappy ^
    --ignore github.com/klauspost/compress/huff0 ^
    --ignore github.com/klauspost/compress/internal/cpuinfo ^
    --ignore github.com/klauspost/compress/s2 ^
    --ignore github.com/klauspost/compress/zstd ^
    --ignore github.com/klauspost/compress/zstd/internal/xxhash ^
    --ignore github.com/klauspost/cpuid/v2 ^
    --ignore github.com/klauspost/reedsolomon ^
    --ignore github.com/mattn/go-localereader ^
    --ignore github.com/minio/colorjson ^
    --ignore github.com/minio/console ^
    --ignore github.com/minio/console/models ^
    --ignore github.com/minio/console/restapi ^
    --ignore github.com/minio/csvparser ^
    --ignore github.com/minio/dperf/pkg/dperf ^
    --ignore github.com/minio/filepath ^
    --ignore github.com/minio/highwayhash ^
    --ignore github.com/minio/kes-go ^
    --ignore github.com/minio/madmin-go/v3 ^
    --ignore github.com/minio/mc/cmd ^
    --ignore github.com/minio/mc/pkg ^
    --ignore github.com/minio/md5-simd ^
    --ignore github.com/minio/minio ^
    --ignore github.com/minio/minio/cmd ^
    --ignore github.com/minio/pkg ^
    --ignore github.com/minio/sha256-simd ^
    --ignore github.com/minio/simdjson-go ^
    --ignore github.com/modern-go/reflect2 ^
    --ignore github.com/pierrec/lz4 ^
    --ignore github.com/pierrec/lz4/v4/internal/lz4block ^
    --ignore github.com/shirou/gopsutil/v3/disk ^
    --ignore github.com/shirou/gopsutil/v3/host ^
    --ignore github.com/zeebo/xxh3 ^
    --ignore golang.org/x/crypto/argon2 ^
    --ignore golang.org/x/crypto/blake2b ^
    --ignore golang.org/x/crypto/chacha20 ^
    --ignore golang.org/x/crypto/chacha20poly1305 ^
    --ignore golang.org/x/crypto/internal/poly1305 ^
    --ignore golang.org/x/crypto/salsa20/salsa ^
    --ignore golang.org/x/crypto/sha3 ^
    --ignore golang.org/x/net/internal/socket ^
    --ignore golang.org/x/sys/cpu ^
    --ignore golang.org/x/sys/unix
if %errorlevel% neq 0 exit /b %errorlevel%
