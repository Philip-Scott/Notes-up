# JS File Assets. Cannot be removed to keep compatibility
file(GLOB assets "${CMAKE_CURRENT_SOURCE_DIR}/assets/highlightjs/**")
install (FILES ${assets}
  DESTINATION ${DATADIR}/notes-up/)

file(GLOB mathassets "${CMAKE_CURRENT_SOURCE_DIR}/assets/mathjax/**")
install (FILES ${mathassets}
  DESTINATION ${DATADIR}/notes-up/)

# install the appdata
install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/com.github.philip-scott.notes-up.appdata.xml
  DESTINATION ${DATADIR}/metainfo/)

# Installing .desktop file
install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/com.github.philip-scott.notes-up.desktop
  DESTINATION ${DATADIR}/applications/)

# Installing Icons
install(FILES "${CMAKE_CURRENT_SOURCE_DIR}/icons/48/com.github.philip-scott.notes-up.svg"
  DESTINATION share/icons/hicolor/48x48/apps)

install(FILES "${CMAKE_CURRENT_SOURCE_DIR}/icons/64/com.github.philip-scott.notes-up.svg"
  DESTINATION share/icons/hicolor/64x64/apps)
