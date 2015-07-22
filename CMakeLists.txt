cmake_minimum_required(VERSION 2.8.12)
project(ragel)

option("RAGEL_ENABLE_TESTS" "Enable tests" OFF)

include(CMakePrintHelpers)

file(STRINGS configure.in configure_in)
string(REGEX MATCH "[ \t;]*AC_INIT\\([^,]*,[ \t]*([^ \t)]+)[ \t]*\\)[ \t;]*"
    _ "${configure_in}") #AC_INIT(ragel, 6.9)
set(VERSION "${CMAKE_MATCH_1}")
string(REGEX MATCH "[ \t;]*PUBDATE=\"([^\"]*)\"[ \t;]*"
    _ "${configure_in}") #PUBDATE="Oct 2014"
set(PUBDATE "${CMAKE_MATCH_1}")

include(CheckIncludeFile)
check_include_file(unistd.h HAVE_UNISTD_H)
configure_file(cmake/config.h.in ${PROJECT_BINARY_DIR}/include/config.h)

if(MSVC)
    add_definitions(/D_CRT_SECURE_NO_WARNINGS /wd4244 /wd4996 /wd4800 /wd4250)
endif()

add_subdirectory(ragel)

if(RAGEL_ENABLE_TESTS)
    enable_testing()
    add_subdirectory(test)
endif()

#[=[
DIST_SUBDIRS = $(SUBDIRS) aapl contrib examples test
]=]
