#!/bin/bash
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
mathjax="$(dirname "${script_dir}")/lib/mathjax/MathJax.js"
if [ -f "$mathjax" ]; then
    script="${script_dir}/mathjax-path"
    echo "#!/bin/bash" > "$script"
    echo "echo \"${mathjax}\"" >> "$script"
    chmod +x "$script"
else
    echo -e "Error: $mathjax file was not found"
    exit 1
fi
