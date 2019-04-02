include (Translations)
add_translations_directory (${GETTEXT_PACKAGE})
add_translations_catalog (${GETTEXT_PACKAGE} ../src
    APPDATA_FILES
        ../data/org.pantheon.audience.appdata.xml.in
)
