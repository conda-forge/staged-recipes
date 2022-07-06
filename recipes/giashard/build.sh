
go mod tidy

cd ./cmd

for tool in $(ls); do
    echo "Building: $tool"
    go build -o "$PREFIX/bin" "./$tool"
done

echo "Done"
