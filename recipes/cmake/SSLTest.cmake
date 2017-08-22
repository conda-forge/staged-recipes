set(FILE_NAME "LICENSE")
set(DOWNLOAD_URL "https://raw.githubusercontent.com/conda-forge/cmake-feedstock/master/${FILE_NAME}")
set(EXPECTED_SHA256 "89593722a0290d7c22dba528a21126881eba4df1ec1be7c47380ffb58c13d5a4")

file(DOWNLOAD ${DOWNLOAD_URL} ${CMAKE_CURRENT_BINARY_DIR}/${FILE_NAME}
 SHOW_PROGRESS
 EXPECTED_HASH  SHA256=${EXPECTED_SHA256}
 STATUS STATUS
 TLS_VERIFY on )

list( GET STATUS 0 RET )
list( GET STATUS 1 MESSAGE )

if( NOT RET EQUAL 0 )
  message(FATAL "Error Downloading file: ${MESSAGE}")
endif()
