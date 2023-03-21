if not exist %PREFIX% mkdir %PREFIX%
mkdir %PREFIX%/cuda-cupti

move lib\* %LIBRARY_LIB%
move include\* %LIBRARY_INC%
move doc %PREFIX%/cuda-cupti
move samples %PREFIX%/cuda-cupti
