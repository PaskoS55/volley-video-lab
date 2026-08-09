cmake_minimum_required(VERSION 3.21)
project(VolleyVideoLabPrototype VERSION 0.0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml Quick Multimedia QuickControls2)
qt_standard_project_setup()

qt_add_executable(VolleyVideoLab
    src/main.cpp
    src/ReviewController.cpp
    src/ReviewController.h
)

qt_add_qml_module(VolleyVideoLab
    URI VolleyVideoLab
    VERSION 1.0
    QML_FILES
        qml/Main.qml
        qml/VideoOverlay.qml
)

target_link_libraries(VolleyVideoLab PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::Multimedia
    Qt6::QuickControls2
)

install(TARGETS VolleyVideoLab
    BUNDLE DESTINATION .
    RUNTIME DESTINATION bin
)
