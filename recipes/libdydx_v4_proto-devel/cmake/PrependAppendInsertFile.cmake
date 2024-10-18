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
    "Coin::mutable_denom"
    "Coin::mutable_amount"
    "SignDoc::mutable_body_bytes"
    "SignDoc::mutable_auth_info_bytes"
    "SignDoc::mutable_chain_id"
    "PubKey::mutable_key"
    "SubaccountId::mutable_owner"
)
set(METHODS_TO_MODIFY
    "Coin::mutable_denom"
    "Coin::mutable_amount"
    "SignDoc::mutable_body_bytes"
    "SignDoc::mutable_auth_info_bytes"
    "SignDoc::mutable_chain_id"
    "PubKey::mutable_key"
    "SubaccountId::mutable_owner"
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
        set(MODIFIED_CONTENT "${INPUT_CONTENT}")

        foreach(METHOD ${METHODS_TO_MODIFY})
            string(REGEX REPLACE "(.*)::(.*)$" "\\1" CLASS_NAME "${METHOD}")
            string(REGEX REPLACE "(.*)::(.*)$" "\\2" METHOD_NAME "${METHOD}")

            # Look for the method definition
            string(REGEX MATCH "inline std::string\\* ${CLASS_NAME}::${METHOD_NAME}\\([^)]*\\)[^\n]*\n" METHOD_DEFINITION "${MODIFIED_CONTENT}")

            if(METHOD_DEFINITION)
                # Modify the method definition to include DYDX_V4_PROTO_API
                string(REGEX REPLACE "inline (std::string\\* ${CLASS_NAME}::${METHOD_NAME}\\([^)]*\\))" "inline DYDX_V4_PROTO_API \\1" MODIFIED_DEFINITION "${METHOD_DEFINITION}")

                # Replace the old definition with the new one
                string(REPLACE "${METHOD_DEFINITION}" "${MODIFIED_DEFINITION}" MODIFIED_CONTENT "${MODIFIED_CONTENT}")
            endif()
        endforeach()
        # set(INSERTION_DONE FALSE)
        # foreach(METHOD ${MISSING_METHODS})
        #     string(REGEX MATCH "${METHOD}" METHOD_FOUND "${INSERTED_CONTENT}")
        #     if(METHOD_FOUND)
        #         string(REGEX REPLACE "(.*)::.*" "\\1" CLASS_NAME ${METHOD})
        #         string(REGEX MATCH "class[^\n]*${CLASS_NAME}[^\n]*\\{" CLASS_START "${INPUT_CONTENT}")
        #         if(CLASS_START)
        #             # Insert the new method after the class opening brace
        #             string(REPLACE "${CLASS_START}" "${CLASS_START}\n  DYDX_V4_PROTO_API std::string* ${METHOD}();" MODIFIED_CONTENT "${MODIFIED_CONTENT}")
        #             set(INSERTION_DONE TRUE)
        #             break()
        #         endif()
        #     endif()
        # endforeach()

    else()
        message(FATAL_ERROR "Invalid OPERATION: ${OPERATION}. Must be either PREPEND or APPEND.")
    endif()

    file(WRITE ${OUTPUT_FILE} "${MODIFIED_CONTENT}")
endforeach()
