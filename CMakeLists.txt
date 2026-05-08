cmake_minimum_required(VERSION 3.16)

project(FusionScantradQt)

set(CMAKE_CXX_STANDARD 17)

find_package(Qt6 REQUIRED COMPONENTS Widgets)

qt_standard_project_setup()

qt_add_executable(FusionScantradQt
        main.cpp
        MainWindow.cpp
        MainWindow.h
        MainWindow.ui
)

target_link_libraries(FusionScantradQt PRIVATE Qt6::Widgets)