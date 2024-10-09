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


# Output 0 of UnbindBackward0 is a view and is being modified inplace. This view is the output of a function that returns multiple views. Such functions do not allow the output views to be modified inplace. You should replace the inplace operation by an out-of-place one.
# TestAutogradLfilterCPU
# test_deemphasis

# 'torchaudio' object has no attribute 'rnnt_loss'
# rnnt

# 'torchaudio' object has no attribute 'ray_tracing'
# ray_tracing

# ValueError: invalid version number '0.10.2.post1'
# test_create_mel

# RuntimeError: torchaudio.functional._alignment.forced_align Requires alignment extension, but TorchAudio is not compiled with it.         Please build TorchAudio with alignment support.
# test_forced_align

# Very slow on CI:
# hubert_large
# hubert_xlarge
# wavlm_large
# test_masking_iid
# test_mvdr_0_ref_channel
# test_rtf_mvdr
# test_souden_mvdr

# Segfault on CI (probably due to limited memory):
# test_pitch_shift_shape_2
# test_paper_configuration

pytest -v test/torchaudio_unittest/ -k "not TestAutogradLfilterCPU and not test_deemphasis and not rnnt and not ray_tracing and not test_create_mel and not test_forced_align and not hubert_large and not hubert_xlarge and not wavlm_large and not test_masking_iid and not test_mvdr_0_ref_channel and not test_rtf_mvdr and not test_souden_mvdr and not test_pitch_shift_shape_2 and not test_paper_configuration"
