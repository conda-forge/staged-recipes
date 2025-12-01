# MarkDiffusion

MarkDiffusion is an open-source Python toolkit for generative watermarking of latent diffusion models.  
This package provides unified watermarking algorithms, watermark mechanism visualization tools, and
comprehensive evaluation pipelines covering detectability, robustness, and image/video quality.

Upstream repository: https://github.com/THU-BPM/MarkDiffusion  
License: Apache-2.0

## Installation

Stable builds of this package are available from conda-forge:

```bash
conda install -c conda-forge markdiffusion
```
This package installs the core MarkDiffusion modules.  
Some optional dependencies required for specific functionalities are not bundled in the conda package.

## Optional Dependencies

Some parts of MarkDiffusion rely on pip-only packages.  
Please install them manually if your workflow requires them:

```bash
pip install huggingface-hub==0.34.2
pip install pyiqa==0.1.14.1
```

These optional packages are needed for:
- `huggingface-hub`: loading pretrained models stored in the Generative-Watermark-Toolkits repository  
- `pyiqa`: image quality assessment metrics used in evaluation modules

## Usage

Below is a minimal example of using MarkDiffusion to generate and detect watermarks:

```python
from watermark.auto_watermark import AutoWatermark
from utils.diffusion_config import DiffusionConfig
from diffusers import StableDiffusionPipeline, DPMSolverMultistepScheduler
import torch

scheduler = DPMSolverMultistepScheduler.from_pretrained("model_path", subfolder="scheduler")
pipe = StableDiffusionPipeline.from_pretrained("model_path", scheduler=scheduler).to("cuda")

diffusion_config = DiffusionConfig(
    scheduler=scheduler,
    pipe=pipe,
    device="cuda",
    image_size=(512, 512),
    num_inference_steps=50,
    guidance_scale=7.5,
    gen_seed=42,
    inversion_type="ddim"
)

wm = AutoWatermark.load("TR", algorithm_config="config/TR.json", diffusion_config=diffusion_config)
img = wm.generate_watermarked_media("A beautiful sunset over the ocean")
result = wm.detect_watermark_in_media(img)
print(result)
```

For more examples and detailed documentation, see the upstream repository.

## Optional Model Downloads
Some watermarking algorithms require pre-trained models.
These models have been removed from the GitHub repository to reduce size.

The code will automatically download the required weights from the Hugging Face repository:

https://huggingface.co/Generative-Watermark-Toolkits

## Support
For issues, please file them in the upstream GitHub repository:

https://github.com/THU-BPM/MarkDiffusion/issues