project(notes-up)

cmake_minimum_required(VERSION 2.6)

# build the markdown lib
include(ExternalProject)
set(DISCOUNT_DEP_PATH ${CMAKE_SOURCE_DIR}/deps/discount)
set(DISCOUNT_LIB_PATH ${CMAKE_BINARY_DIR}/libmarkdown.a)
set(DISCOUNT_INCLUDE_PATH ${DISCOUNT_DEP_PATH})

ExternalProject_Add(discount
  PREFIX ${DISCOUNT_DEP_PATH}
  SOURCE_DIR ${DISCOUNT_DEP_PATH}
  CONFIGURE_COMMAND
      ${DISCOUNT_DEP_PATH}/configure.sh --src=${DISCOUNT_DEP_PATH}
                                        --with-fenced-code
                                        --prefix=${CMAKE_BINARY_DIR}
                                        --libdir=${CMAKE_BINARY_DIR}
  BUILD_COMMAND make install
  BUILD_IN_SOURCE 1
)

include_directories(${DISCOUNT_INCLUDE_PATH})

# build UI lib
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)

# disable C compiler warnings
add_definitions(-w)

find_package(PkgConfig)

# either of webkitpackages would do
pkg_search_module(WEBKIT REQUIRED
  webkit2gtk-4.0
  webkit2gtk-3.0
)

pkg_check_modules(DEPS REQUIRED
  granite>=0.3
  gtksourceview-3.0>=3.10
  gthread-2.0
  gtk+-3.0>=3.9.10
  sqlite3>=3.5.9
)

set (PKG_DEPS
 granite>=0.3
 gee-0.8
 gtksourceview-3.0
 gtk+-3.0
 webkit2gtk-4.0
 sqlite3>=3.5.9
 discount
)

set (VALA_DEPS
 granite
 gee-0.8
 gtksourceview-3.0
 gtk+-3.0
 webkit2gtk-4.0
 sqlite3
 discount
)

pkg_check_modules (DEPS REQUIRED ${PKG_DEPS})

add_definitions(${DEPS_CFLAGS})
add_definitions(${WEBKIT_CFLAGS})

link_libraries(${DEPS_LIBRARIES})
link_libraries(${WEBKIT_LIBRARIES})

link_directories(${DEPS_LIBRARY_DIRS})
link_directories(${WEBKIT_LIBRARY_DIRS})
link_directories(${CMAKE_BINARY_DIR})

include_directories(${CMAKE_BINARY_DIR})
include_directories(${CMAKE_SOURCE_DIR})

set (generated_resources ${generated_resource})

find_package(Vala REQUIRED)
include(ValaVersion)
ensure_vala_version("0.26.0" MINIMUM)

set (DATADIR "${CMAKE_INSTALL_PREFIX}/share")
set (PKGDATADIR "${DATADIR}/notes-up")
set (GETTEXT_PACKAGE "notes-up")
set (RELEASE_NAME "TARS")
set (VERSION "1.3")
set (VERSION_INFO "Release")
set (CMAKE_C_FLAGS "-ggdb")
set (PREFIX ${CMAKE_INSTALL_PREFIX})
set (DOLLAR "$")

configure_file (${CMAKE_SOURCE_DIR}/src/config.vala.cmake ${CMAKE_SOURCE_DIR}/src/config.vala)
add_definitions (-DGETTEXT_PACKAGE=\"${GETTEXT_PACKAGE}\")

add_subdirectory (po)
add_subdirectory (schemas)

include(ValaPrecompile)

set (BASIC_VALAC_OPTIONS
  -g
   --vapidir=${CMAKE_SOURCE_DIR}/vapi
   --thread
   --target-glib=2.38
)

set (GLOBAL_VALAC_OPTIONS
  ${BASIC_VALAC_OPTIONS}
)

SET(noele false CACHE BOOL "Remove elementaryOS-only features")

if (noele)
    set (GLOBAL_VALAC_OPTIONS ${GLOBAL_VALAC_OPTIONS} --define=REMOVE_ELEMENTARY_FEATURES)
    message ("-- CONTRACTOR disabled")
endif (noele)

vala_precompile(VALA_C
  src/Main.vala
  src/Application.vala
  src/Widgets/Editor.vala
  src/Widgets/Headerbar.vala
  src/Widgets/ViewEditStack.vala
  src/Widgets/NewNotebookDialog.vala
  src/Widgets/PreferencesDialog.vala
  src/Widgets/NotebookItem.vala
  src/Widgets/BookmarkItem.vala
  src/Widgets/TrashItem.vala
  src/Widgets/ToolbarButton.vala
  src/Widgets/BookmarkButton.vala
  src/Widgets/PageItem.vala
  src/Widgets/PagesList.vala
  src/Widgets/Sidebar.vala
  src/Widgets/SidebarItem.vala
  src/Widgets/Viewer.vala
  src/Widgets/Window.vala
  
  src/Styles/air.vala
  src/Styles/elementary.vala
  src/Styles/modest.vala
  
  src/Services/Bookmark.vala
  src/Services/FileManager.vala
  src/Services/Notebook.vala
  src/Services/Image.vala
  src/Services/Page.vala
  src/Services/Settings.vala
  src/Services/Trash.vala
  src/Services/DatabaseTable.vala
  
  src/Plugins/Manager.vala
  src/Plugins/Plugin.vala
  src/Plugins/Break.vala
  src/Plugins/Color.vala
  src/Plugins/Youtube.vala
  src/Plugins/Image.vala
  src/Plugins/Highlight.vala
  src/config.vala
PACKAGES
  ${VALA_DEPS}
OPTIONS
  ${GLOBAL_VALAC_OPTIONS}
)

add_executable(notes-up ${VALA_C} ${generated_resources})

target_link_libraries(notes-up
  ${DISCOUNT_LIB_PATH})

add_dependencies(notes-up
  discount
)

install(TARGETS notes-up RUNTIME
  DESTINATION bin)

install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/com.github.philip-scott.notes-up.appdata.xml
  DESTINATION ${DATADIR}/metainfo/)

install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/com.github.philip-scott.notes-up.desktop
  DESTINATION ${DATADIR}/applications/)

#install assets
file(GLOB assets "${CMAKE_CURRENT_SOURCE_DIR}/data/assets/**")
install (FILES ${assets}
  DESTINATION ${DATADIR}/notes-up/)
install(FILES "${CMAKE_CURRENT_SOURCE_DIR}/data/com.github.philip-scott.notes-up.svg"
  DESTINATION ${DATADIR}/pixmaps/)

# App DATA
#configure_file_translation (io.github.notes-up.xml.in ${CMAKE_CURRENT_BINARY_DIR}/io.github.notes-up.xml ${CMAKE_SOURCE_DIR}/po/)
#install (FILES ${CMAKE_CURRENT_BINARY_DIR}/io.github.notes-up.xml DESTINATION ${DATADIR}/appdata/)


