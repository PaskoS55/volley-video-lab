cmake_minimum_required(VERSION 3.21)

project(VolleyVideoLab
    VERSION 0.0.1
    LANGUAGES CXX
)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt6 6.5 REQUIRED COMPONENTS
    Quick
    Multimedia
    Core
    Gui
)

qt_add_executable(VolleyVideoLab
    WIN32
    src/main.cpp
    resources.qrc
)

target_link_libraries(VolleyVideoLab PRIVATE
    Qt6::Quick
    Qt6::Multimedia
    Qt6::Core
    Qt6::Gui
)
