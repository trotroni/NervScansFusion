cmake_minimum_required(VERSION 3.22)

project(NervScansFusion VERSION 1.2.7 LANGUAGES CXX)

# ── Standard C++17 ───────────────────────────────────────────────────────────
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# ── Qt6 configuration ────────────────────────────────────────────────────────
# Active l'auto-moc, auto-uic et auto-rcc (obligatoire pour Qt)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTORCC ON)

# ── Trouver Qt6 ──────────────────────────────────────────────────────────────
find_package(Qt6 REQUIRED COMPONENTS Core Gui Widgets)
# Ajoute les composants que tu utilises :
# find_package(Qt6 REQUIRED COMPONENTS Core Gui Widgets Network Sql Svg)

# ── Sources ──────────────────────────────────────────────────────────────────
set(SOURCES
        main.cpp
        MainWindow.cpp
        MainWindow.h
        MainWindow.ui
        # resources/resources.qrc  # décommente si tu as des ressources Qt
)

# ── Exécutable ───────────────────────────────────────────────────────────────
# qt_add_executable gère les spécificités macOS (.app) et Windows (WinMain)
qt_add_executable(NervScansFusion
        MANUAL_FINALIZATION   # nécessaire pour le bundle macOS
        ${SOURCES}
)

# ── Liens Qt ──────────────────────────────────────────────────────────────────
target_link_libraries(NervScansFusion PRIVATE
        Qt6::Core
        Qt6::Gui
        Qt6::Widgets
)

# ── macOS : bundle .app correct ───────────────────────────────────────────────
if(APPLE)
    set_target_properties(NervScansFusion PROPERTIES
            MACOSX_BUNDLE TRUE
            MACOSX_BUNDLE_BUNDLE_NAME        "NervScansFusion"
            MACOSX_BUNDLE_BUNDLE_VERSION     ${PROJECT_VERSION}
            MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION}
            MACOSX_BUNDLE_GUI_IDENTIFIER     "com.NervScans.NervScansFusion"
            # MACOSX_BUNDLE_ICON_FILE        "AppIcon.icns"  # décommente si tu as une icône
    )
    # Déplace l'icône dans le bundle si elle existe
    # set_source_files_properties(resources/AppIcon.icns
    #     PROPERTIES MACOSX_PACKAGE_LOCATION "Resources"
    # )
endif()

# ── Windows : pas de fenêtre console ─────────────────────────────────────────
if(WIN32)
    set_target_properties(NervScansFusion PROPERTIES
            WIN32_EXECUTABLE TRUE           # supprime la console CMD
    )
endif()

# ── Finalisation Qt (obligatoire avec MANUAL_FINALIZATION) ────────────────────
qt_finalize_executable(NervScansFusion)

# ── Installation (optionnel, pour CPack) ──────────────────────────────────────
install(TARGETS NervScansFusion
        BUNDLE  DESTINATION .    # macOS : copie le .app
        RUNTIME DESTINATION bin  # Windows/Linux : copie l'exe
)