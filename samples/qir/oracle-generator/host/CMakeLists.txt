set(CMAKE_CXX_STANDARD 17)

set(QSHARP_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../qsharp)
set(QIR_FILE ${QSHARP_DIR}/qir/project.ll)
set(QIR_OUT_FILE ${QSHARP_DIR}/qir/project-out.ll)
add_custom_target(compile-qsharp
    COMMAND dotnet build
    WORKING_DIRECTORY ${QSHARP_DIR}
    BYPRODUCTS ${QIR_FILE}
)

add_custom_target(generate-qir-oracle
    COMMAND oracle_generator ${QIR_FILE} ${QIR_OUT_FILE}
    DEPENDS oracle_generator compile-qsharp
    BYPRODUCTS ${QIR_OUT_FILE}
    COMMENT invoking oracle generator on generated QIR   
    VERBATIM
)

set_source_files_properties(${QIR_OUT_FILE} PROPERTIES LANGUAGE CXX)
add_library(qir-obj OBJECT ${QIR_OUT_FILE})
set_target_properties(qir-obj PROPERTIES LINKER_LANGUAGE CXX)
add_dependencies(qir-obj generate-qir-oracle)

add_executable(host_program main.cpp)
target_include_directories(host_program SYSTEM PUBLIC ${QSHARP_DIR}/bin/Debug/net6.0/runtimes/any/native/include)
target_link_libraries(host_program qir-obj)
if(UNIX)
    if(APPLE)
        target_link_directories(host_program PUBLIC ${QSHARP_DIR}/bin/Debug/net6.0/runtimes/osx-x64/native)
    else()
        target_link_directories(host_program PUBLIC ${QSHARP_DIR}/bin/Debug/net6.0/runtimes/linux-x64/native)
    endif()
elseif(WIN32)
    target_link_directories(host_program PUBLIC ${QSHARP_DIR}/bin/Debug/net6.0/runtimes/win-x64/native)
endif()
target_link_libraries(host_program Microsoft.Quantum.Qir.Runtime)
target_link_libraries(host_program Microsoft.Quantum.Qir.QSharp.Foundation)
target_link_libraries(host_program Microsoft.Quantum.Qir.QSharp.Core)
