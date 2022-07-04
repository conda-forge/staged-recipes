
go mod tidy

cd ./cmd

for tool in $(ls); do
    go build -o "$PREFIX/bin" "./$tool"
done
