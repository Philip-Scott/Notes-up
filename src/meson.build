
conf = configuration_data()
conf.set_quoted('PROJECT_NAME', meson.project_name())
conf.set_quoted('GETTEXT_PACKAGE', meson.project_name())
conf.set_quoted('VERSION', meson.project_version())
conf.set_quoted('PREFIX', get_option('prefix'))
conf.set_quoted('DATADIR', join_paths (get_option('prefix'), get_option('datadir')))
conf.set_quoted('LOCALEDIR', join_paths (get_option('prefix'), get_option('localedir')))
config = configure_file(
    input : 'Constants.vala.in',
    output : 'Constants.vala',
    configuration : conf
)


sources = files(
    'Main.vala',
    'Application.vala',

    'GranitePatches/SourceList.vala',

    'Widgets/Editor.vala',
    'Widgets/HelpBox.vala',
    'Widgets/Headerbar.vala',
    'Widgets/NotebookPicker.vala',
    'Widgets/ViewEditStack.vala',
    'Widgets/ToolbarButton.vala',
    'Widgets/BookmarkButton.vala',
    'Widgets/PageItem.vala',
    'Widgets/PageInfoEditor.vala',
    'Widgets/PagesList.vala',
    'Widgets/Viewer.vala',
    'Widgets/Window.vala',

    'Widgets/Sidebar/Sidebar.vala',
    'Widgets/Sidebar/SidebarItem.vala',
    'Widgets/Sidebar/NotebookList.vala',
    'Widgets/Sidebar/NotebookItem.vala',
    'Widgets/Sidebar/BookmarkItem.vala',
    'Widgets/Sidebar/TagItem.vala',
    'Widgets/Sidebar/TrashItem.vala',

    'Widgets/Dialogs/NewNotebookDialog.vala',
    'Widgets/Dialogs/PreferencesDialog.vala',
    'Widgets/Dialogs/NotebookListDialog.vala',

    'Services/Bookmark.vala',
    'Services/FileData.vala',
    'Services/FileManager.vala',
    'Services/Notebook.vala',
    'Services/Image.vala',
    'Services/Page.vala',
    'Services/Settings.vala',
    'Services/StyleLoader.vala',
    'Services/Trash.vala',
    'Services/Tags.vala',
    'Services/DatabaseTable.vala',
    'Services/WordWrapper.vala',

    'Plugins/Manager.vala',
    'Plugins/Plugin.vala',
    'Plugins/Break.vala',
    'Plugins/Color.vala',
    'Plugins/Youtube.vala',
    'Plugins/Image.vala',
    'Plugins/PageLink.vala',
    'Plugins/Highlight.vala'
)
