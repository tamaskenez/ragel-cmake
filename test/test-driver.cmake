file(APPEND testlog.txt "testlog for ${TEST_NAME}
    RAGEL_EXECUTABLE=${RAGEL_EXECUTABLE}
    lang_opt=${lang_opt}
    min_opt=${min_opt}
    gen_opt=${gen_opt}
    TEST_CODE_SRC=${TEST_CODE_SRC}
    test_case=${test_case}
    TEST_CASE_SOURCE_DIR=${TEST_CASE_SOURCE_DIR}
    TEST_INCLUDE_DIR_SCRIPT=${TEST_INCLUDE_DIR_SCRIPT}
    TEST_CONFIG=${TEST_CONFIG}
    TEST_BINARY_DIR=${TEST_BINARY_DIR}
    TEST_SOURCE_DIR=${TEST_SOURCE_DIR}
    ")

execute_process(
    COMMAND "${RAGEL_EXECUTABLE}"
        ${lang_opt} ${min_opt} ${gen_opt}
        -o ${TEST_CODE_SRC}
        ${test_case}
    WORKING_DIRECTORY ${TEST_CASE_SOURCE_DIR}
    OUTPUT_FILE "${TEST_BINARY_DIR}/${TEST_NAME}-ragel-stdout.txt"
    ERROR_FILE "${TEST_BINARY_DIR}/${TEST_NAME}-ragel-stderr.txt"
    RESULT_VARIABLE result
)

if(result)
    message(FATAL_ERROR "Ragel failed: ${result}")
endif()

execute_process(
    COMMAND ${CMAKE_COMMAND}
        -DTEST_CODE_SRC=${TEST_CODE_SRC}
        -DTEST_INCLUDE_DIR_SCRIPT=${TEST_INCLUDE_DIR_SCRIPT}
        -DCMAKE_BUILD_TYPE=${TEST_CONFIG}
        -DCMAKE_INSTALL_PREFIX=${TEST_BINARY_DIR}
        -DTEST_CASE_SOURCE_DIR=${TEST_CASE_SOURCE_DIR}
        ${TEST_SOURCE_DIR}
    WORKING_DIRECTORY ${TEST_BINARY_DIR}
    OUTPUT_FILE "${TEST_BINARY_DIR}/${TEST_NAME}-cmake-config-stdout.txt"
    ERROR_FILE "${TEST_BINARY_DIR}/${TEST_NAME}-cmake-config-stderr.txt"
    RESULT_VARIABLE result
)

if(result)
    message(FATAL_ERROR "Failed to configure test-exe: ${result}")
endif()

execute_process(
    COMMAND ${CMAKE_COMMAND}
        --build ${TEST_BINARY_DIR}
        --target install
        --config ${TEST_CONFIG}
    RESULT_VARIABLE result
    OUTPUT_FILE "${TEST_BINARY_DIR}/${TEST_NAME}-cmake-build-stdout.txt"
    ERROR_FILE "${TEST_BINARY_DIR}/${TEST_NAME}-cmake-build-stderr.txt"
)

if(result)
    message(FATAL_ERROR "Failed to build test-exe: ${result}")
endif()

find_program(TEST_EXECUTABLE "test-exe" PATHS ${TEST_BINARY_DIR}/bin NO_DEFAULT_PATH)
execute_process(COMMAND ${TEST_EXECUTABLE}
    OUTPUT_FILE "${TEST_BINARY_DIR}/${TEST_NAME}-stdout.txt"
    ERROR_FILE "${TEST_BINARY_DIR}/${TEST_NAME}-stderr.txt"
    RESULT_VARIABLE result
)

if(result)
    message(FATAL_ERROR "Failed to run test-exe: ${result}")
endif()

file(STRINGS "${TEST_BINARY_DIR}/${TEST_NAME}-stdout.txt" output)
file(STRINGS "${TEST_EXPECTED_OUT}" exp)

# strip trailing empty lines
string(REGEX REPLACE ";+$" "" output "${output}")
string(REGEX REPLACE ";+$" "" exp "${exp}")

if(NOT output STREQUAL exp)
    message(FATAL_ERROR "Output differs from expected")
endif()





