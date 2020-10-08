 #!/bin/bash
 # post install EULA message; `pre-link.sh` does not show message and shows warning
echo "By downloading and using the CUDA Toolkit conda packages, you accept the terms and conditions of the CUDA End User License Agreement (EULA): https://docs.nvidia.com/cuda/eula/index.html" >> $PREFIX/.messages.txt
