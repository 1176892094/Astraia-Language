cmake_minimum_required(VERSION 3.20)

project(Astraia_Language)

set(CMAKE_CXX_STANDARD 20)

# 使用 main.mm
set(SOURCES main.mm)

add_executable(Astraia_Language ${SOURCES})

# 编译为 Objective-C++
set_source_files_properties(${SOURCES} PROPERTIES
        COMPILE_FLAGS "-x objective-c++"
)

# 链接 Cocoa 框架
target_link_libraries(Astraia_Language "-framework Cocoa")