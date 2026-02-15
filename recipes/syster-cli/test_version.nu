def main [git_tag: string] {
    let result = (^syster --version | complete)
    if $result.exit_code != 0 {
        error make {msg: $"syster --version failed with exit code ($result.exit_code)"}
    }
    let escaped = ($git_tag | str replace --all '.' '\.')
    let expected = '(?i)^syster ' + $escaped + '$'
    if ($result.stdout | str trim) !~ $expected {
        error make {msg: $"version mismatch: got '($result.stdout | str trim)', expected pattern '($expected)'"}
    }
}
