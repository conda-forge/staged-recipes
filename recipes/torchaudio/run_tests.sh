#!/bin/bash
set -ex

export CI=true

export TORCHAUDIO_TEST_ALLOW_SKIP_IF_NO_CMD_APPLY_CMVN_SLIDING="true"
export TORCHAUDIO_TEST_ALLOW_SKIP_IF_NO_CMD_COMPUTE_FBANK_FEATS="true"
export TORCHAUDIO_TEST_ALLOW_SKIP_IF_NO_CMD_COMPUTE_KALDI_PITCH_FEATS="true"
export TORCHAUDIO_TEST_ALLOW_SKIP_IF_NO_CMD_COMPUTE_MFCC_FEATS="true"
export TORCHAUDIO_TEST_ALLOW_SKIP_IF_NO_CMD_COMPUTE_SPECTROGRAM_FEATS="true"
export TORCHAUDIO_TEST_ALLOW_SKIP_IF_NO_KALDI="true"
export TORCHAUDIO_TEST_ALLOW_SKIP_IF_NO_CUDA="true"
export TORCHAUDIO_TEST_ALLOW_SKIP_IF_NO_HW_ACCEL="true"
export TORCHAUDIO_TEST_ALLOW_SKIP_IF_ON_PYTHON_310="true"
export TORCHAUDIO_TEST_ALLOW_SKIP_IF_NO_AUDIO_OUT_DEVICE="true"
export TORCHAUDIO_TEST_ALLOW_SKIP_IF_NO_MACOS="true"
export TORCHAUDIO_TEST_ALLOW_SKIP_IF_TEMPORARY_DISABLED="true"
export TORCHAUDIO_TEST_ALLOW_SKIP_IF_NO_SOX_DECODER="true"
export TORCHAUDIO_TEST_ALLOW_SKIP_IF_NO_SOX_ENCODER="true"
export TORCHAUDIO_TEST_ALLOW_SKIP_IF_NO_CTC_DECODER="true"
export TORCHAUDIO_TEST_ALLOW_SKIP_IF_NO_MOD_demucs="true"
export TORCHAUDIO_TEST_ALLOW_SKIP_IF_NO_MOD_fairseq="true"
export TORCHAUDIO_TEST_ALLOW_SKIP_IF_NO_QUANTIZATION="true"
export TORCHAUDIO_TEST_ALLOW_SKIP_IF_NO_RIR="true"
export TORCHAUDIO_TEST_ALLOW_SKIP_IF_NO_FFMPEG="true"
export TORCHAUDIO_TEST_ALLOW_SKIP_IF_NO_SOX="true"


## OVERVIEW OF SKIPPED TESTS

# Output 0 of UnbindBackward0 is a view and is being modified inplace. 
# This view is the output of a function that returns multiple views. 
# Such functions do not allow the output views to be modified inplace. 
# You should replace the inplace operation by an out-of-place one.
tests_to_skip="TestAutogradLfilterCPU"
tests_to_skip="test_deemphasis or ${tests_to_skip}"

# 'torchaudio' object has no attribute 'rnnt_loss'
tests_to_skip="rnnt or ${tests_to_skip}"

# 'torchaudio' object has no attribute 'ray_tracing'
tests_to_skip="ray_tracing or ${tests_to_skip}"

# object has no attribute _simulate_rir:
tests_to_skip="test_simulate_rir or ${tests_to_skip}"

# ValueError: invalid version number '0.10.2.post1'
tests_to_skip="test_create_mel or ${tests_to_skip}"

# RuntimeError: torchaudio.functional._alignment.forced_align Requires alignment extension, but TorchAudio is not compiled with it.
# Please build TorchAudio with alignment support.
tests_to_skip="test_forced_align or ${tests_to_skip}"

# Very slow on CI:
tests_to_skip="hubert_large or ${tests_to_skip}"
tests_to_skip="hubert_xlarge or ${tests_to_skip}"
tests_to_skip="hubert_pretrain_large or ${tests_to_skip}"
tests_to_skip="hubert_pretrain_xlarge or ${tests_to_skip}"
tests_to_skip="wavlm_large or ${tests_to_skip}"
tests_to_skip="test_masking_iid or ${tests_to_skip}"
tests_to_skip="test_mvdr_0_ref_channel or ${tests_to_skip}"
tests_to_skip="test_rtf_mvdr or ${tests_to_skip}"
tests_to_skip="test_souden_mvdr or ${tests_to_skip}"

# Segfault on CI (probably due to limited memory):
tests_to_skip="test_pitch_shift_shape_2 or ${tests_to_skip}"
tests_to_skip="test_paper_configuration or ${tests_to_skip}"
tests_to_skip="test_oscillator_bank or ${tests_to_skip}"
tests_to_skip="test_PitchShift or ${tests_to_skip}"
tests_to_skip="test_pitch_shift_resample_kernel or ${tests_to_skip}"
tests_to_skip="test_quantize_torchscript_1_wav2vec2_large or ${tests_to_skip}"
tests_to_skip="test_quantize_torchscript_2_wav2vec2_large_lv60k or ${tests_to_skip}"


pytest -v test/torchaudio_unittest/ -k "not (${tests_to_skip})"
