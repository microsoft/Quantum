cmake_minimum_required(VERSION 3.11)
project(sample.qir.oracle-generator)
include(FetchContent)

set(CMAKE_CXX_STANDARD 17)

# LLVM dependency
find_package(LLVM 11.1.0 REQUIRED CONFIG)
llvm_map_components_to_libnames(LLVM_LIBS support core irreader scalaropts)

# mockturtle dependency
FetchContent_Declare(
  mockturtle
  GIT_REPOSITORY https://github.com/lsils/mockturtle.git
  GIT_TAG        6b7bc42e8a8dc50070ecd92e6fb039533afcdcdd
)

FetchContent_MakeAvailable(mockturtle)

add_executable(oracle_generator oracle_generator.cpp)
target_compile_definitions(oracle_generator PUBLIC
    DISABLE_NAUTY
    FMT_HEADER_ONLY
)
target_include_directories(oracle_generator SYSTEM PUBLIC
    ${LLVM_INCLUDE_DIRS}
    ${mockturtle_SOURCE_DIR}/include/
    ${mockturtle_SOURCE_DIR}/lib/abcsat/
    ${mockturtle_SOURCE_DIR}/lib/bill/
    ${mockturtle_SOURCE_DIR}/lib/fmt/
    ${mockturtle_SOURCE_DIR}/lib/kitty/
    ${mockturtle_SOURCE_DIR}/lib/lorina/
    ${mockturtle_SOURCE_DIR}/lib/parallel_hashmap/
    ${mockturtle_SOURCE_DIR}/lib/percy/
)
target_link_libraries(oracle_generator PUBLIC ${LLVM_LIBS})
