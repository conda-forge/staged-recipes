if not exist %PREFIX% mkdir %PREFIX%
mkdir %PREFIX%/cuda-cupti
mkdir %PREFIX%/cuda-cupti/docs
mkdir %PREFIX%/cuda-cupti/samples

move lib\* %LIBRARY_LIB%
move include\* %LIBRARY_INC%
move doc\* %PREFIX%/cuda-cupti/docs
move samples\* %PREFIX%/cuda-cupti/samples
