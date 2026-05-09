cmake_minimum_required(VERSION 3.21)

project(NervScansFusion LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTORCC ON)

find_package(Qt6 REQUIRED COMPONENTS Widgets)

qt_standard_project_setup()

qt_add_executable(NervScansFusion
        MANUAL_FINALIZATION
        main.cpp
        MainWindow.cpp
        MainWindow.h
        MainWindow.ui
)

target_link_libraries(NervScansFusion PRIVATE
        Qt6::Widgets
)

# ===== macOS bundle =====
set_target_properties(NervScansFusion PROPERTIES
        MACOSX_BUNDLE TRUE
        WIN32_EXECUTABLE TRUE
)

qt_finalize_executable(NervScansFusion)