project('notes-up','vala', 'c', version: '2.7.0')

APP_ID = 'com.github.philip_scott.@0@'.format (meson.project_name())

gnome = import('gnome')
i18n = import('i18n')

add_global_arguments(
    '-DGETTEXT_PACKAGE="@0@"'.format (meson.project_name()),
    language:'c'
)

asresources = gnome.compile_resources(
    'as-resources', join_paths('data', APP_ID + '.gresource.xml'),
    source_dir: 'data',
    c_name: 'as'
)

subdir('src')

executable(
    meson.project_name(),
    sources,
    config,
    asresources,
    dependencies: [
        dependency('granite'),
        dependency('gee-0.8'),
        dependency('gtksourceview-4'),
        dependency('gtk+-3.0'),
        dependency('webkit2gtk-4.0'),
        dependency('sqlite3', version : '>=3.5.9'),
        dependency('gtkspell3-3.0'),
        dependency('libmarkdown')
    ],
    vala_args: [
        '--vapidir=' + meson.source_root() + '/vapi/',
    ],
    install: true
)

subdir('data')
subdir('po')

meson.add_install_script('meson/post_install.py')
