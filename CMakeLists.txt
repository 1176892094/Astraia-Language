cmake_minimum_required(VERSION 3.20)

# ✅ 启用 C++ 和 Objective-C++
project(Astraia_Language LANGUAGES CXX OBJCXX)

set(CMAKE_CXX_STANDARD 20)

# 添加源文件
add_executable(Astraia_Language main.mm)

# 链接 macOS 框架
target_link_libraries(Astraia_Language
        "-framework Cocoa"
        "-framework Metal"
        "-framework MetalKit"
)