# project name
project (enotes)

# the oldest stable cmake version we support
cmake_minimum_required (VERSION 2.6)

# tell cmake where its modules can be found in our project directory
list (APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)

# where we install data directory (if we have any)
set (DATADIR "${CMAKE_INSTALL_PREFIX}/share")

# what to call that directory where we install data too
set (PKGDATADIR "${DATADIR}/enotes")

set (EXEC_NAME "enotes")
set (RELEASE_NAME "eNotes: beta 1")
set (VERSION "0.1")
set (VERSION_INFO "")

# we're about to use pkgconfig to make sure dependencies are installed so let's find pkgconfig first
find_package(PkgConfig)

# now let's actually check for the required dependencies
pkg_search_module(WEBKIT REQUIRED
#  webkit2gtk-4.0
  webkit2gtk-3.0
)
pkg_check_modules(DEPS REQUIRED 
    granite>=0.3.0
    gtksourceview-3.0
    gtk+-3.0)
add_definitions(${WEBKIT_CFLAGS})
add_definitions(${DEPS_CFLAGS})
link_libraries(${DEPS_LIBRARIES})
link_directories(${DEPS_LIBRARY_DIRS})

# make sure we have vala
find_package(Vala REQUIRED)
# make sure we use vala
include(ValaVersion)
# make sure it's the desired version of vala
ensure_vala_version("0.16" MINIMUM)

# files we want to compile
include(ValaPrecompile)
vala_precompile(VALA_C ${EXEC_NAME}
    src/Main.vala
    src/Application.vala
    src/Widgets/BookmarkItem.vala
    src/Widgets/Editor.vala
    src/Widgets/Headerbar.vala
    src/Widgets/NewNotebookDialog.vala
    src/Widgets/NotebookItem.vala
    src/Widgets/PageItem.vala
    src/Widgets/PagesList.vala
    src/Widgets/Sidebar.vala
    src/Widgets/SidebarItem.vala
    src/Widgets/Viewer.vala
    src/Widgets/Window.vala
    src/Services/FileManager.vala
    src/Services/Settings.vala  
# tell what libraries to use when compiling
PACKAGES
    granite
    gtk+-3.0
    gtksourceview-3.0
    gtk+-3.0
    webkit2gtk-3.0
OPTIONS
  #--vapidir=${CMAKE_SOURCE_DIR}/vapi
  --thread
)



# tell cmake what to call the executable we just made
add_executable(${EXEC_NAME} ${VALA_C})

# install the binaries we just made
install (TARGETS ${EXEC_NAME} RUNTIME DESTINATION bin)

# install our .desktop file so the Applications menu will see it
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/enotes.desktop DESTINATION ${DATADIR}/applications/)


