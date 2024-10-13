# Parameters:
# INSERTED_FILE: The file containing the export macro definitions
# INPUT_FILES: Either a single file or a list of files to process
# OUTPUT_DIR: Directory where the processed files will be written
# OPERATION: "PREPEND" or "APPEND" to specify the operation

if(NOT DEFINED OPERATION)
    set(OPERATION "PREPEND")
endif()

if(NOT INPUT_FILES OR NOT DEFINED INSERTED_FILE OR NOT DEFINED OUTPUT_DIR)
    message(FATAL_ERROR "INPUT_FILES, INSERTED_FILE, OUTPUT_DIR, and OPERATION must be defined")
endif()

file(READ ${INSERTED_FILE} INSERTED_CONTENT)

set(MISSING_METHODS
    "DYDX_V4_PROTO_API std::string* Coin::mutable_denom();"
    "DYDX_V4_PROTO_API std::string* Coin::mutable_amount();"
    "DYDX_V4_PROTO_API std::string* SignDoc::mutable_body_bytes();"
    "DYDX_V4_PROTO_API std::string* SignDoc::mutable_auth_info_bytes();"
    "DYDX_V4_PROTO_API std::string* SignDoc::mutable_chain_id();"
    "DYDX_V4_PROTO_API std::string* PubKey::mutable_key();"
    "DYDX_V4_PROTO_API std::string* SubaccountId::mutable_owner();"
)

foreach(INPUT_FILE IN LISTS INPUT_FILES)
    get_filename_component(FILE_NAME ${INPUT_FILE} NAME)
    set(OUTPUT_FILE "${OUTPUT_DIR}/${FILE_NAME}")
    
    file(READ ${INPUT_FILE} INPUT_CONTENT)

    if(${OPERATION} STREQUAL "PREPEND")
        set(MODIFIED_CONTENT "${INSERTED_CONTENT}\n${INPUT_CONTENT}")
    elseif(${OPERATION} STREQUAL "APPEND")
        set(MODIFIED_CONTENT "${INPUT_CONTENT}\n${INSERTED_CONTENT}")
    elseif(${OPERATION} STREQUAL "INSERT")
        string(REGEX MATCH "// *@@protoc_insertion_point\\(namespace_scope\\)" FOUND_INSERTION_POINT "${INPUT_CONTENT}")
        if(FOUND_INSERTION_POINT)
            set(MODIFIED_CONTENT "${INPUT_CONTENT}")
            set(INSERTION_DONE FALSE)
            foreach(METHOD ${MISSING_METHODS})
                string(REGEX MATCH "${METHOD}" METHOD_FOUND "${INSERTED_CONTENT}")
                if(METHOD_FOUND)
                    string(REPLACE "${FOUND_INSERTION_POINT}" "${FOUND_INSERTION_POINT}\n${INSERTED_CONTENT}" MODIFIED_CONTENT "${INPUT_CONTENT}")
                    set(INSERTION_DONE TRUE)
                    break()
                endif()
            endforeach()
        else()
            set(MODIFIED_CONTENT "${INPUT_CONTENT}")
        endif()
    else()
        message(FATAL_ERROR "Invalid OPERATION: ${OPERATION}. Must be either PREPEND or APPEND.")
    endif()

    file(WRITE ${OUTPUT_FILE} "${MODIFIED_CONTENT}")
endforeach()
