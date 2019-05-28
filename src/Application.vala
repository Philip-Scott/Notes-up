/*
* Copyright (c) 2019 Felipe Escoto (https://github.com/Philip-Scott/Notes-up)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 59 Temple Place - Suite 330,
* Boston, MA 02111-1307, USA.
*
* Authored by: Felipe Escoto <felescoto95@hotmail.com>
*/

public enum ENotes.Key {
    CHANGE_MODE,
    SAVE,
    QUIT,
    NEW_PAGE,
    FIND,
    BOOKMARK,
    BOLD,
    ITALICS,
    STRIKE,
    PAGE_INFO;

    public string to_key () {
        switch (this) {
            /// These keys must be valid since they will be used across the app
            case CHANGE_MODE:   return _("<Ctrl>M");
            case SAVE:          return _("<Ctrl>S");
            case QUIT:          return _("<Ctrl>Q");
            case NEW_PAGE:      return _("<Ctrl><Shift>N");
            case FIND:          return _("<Ctrl>F");
            case BOOKMARK:      return _("<Ctrl>K");
            case BOLD:          return _("<Ctrl>B");
            case ITALICS:       return _("<Ctrl>I");
            case STRIKE:        return _("<Ctrl>T");
            case PAGE_INFO:     return _("<Ctrl><Shift>I");
            default:            assert_not_reached();
        }
    }

    public string to_string () {
        return " (" + this.to_key ().replace (">", "+").replace ("<","") + ")";
    }
}

namespace ENotes {
    public unowned ENotes.Application app;
    public ENotes.Services.Settings settings;
    public string NOTES_DB;
    public string NOTES_DIR;
}

public class ENotes.Application : Granite.Application {
    public const string PROGRAM_NAME = N_("Notes-Up");
    public const string COMMENT = N_("Your Markdown Notebook.");
    public const string ABOUT_STOCK = N_("About Notes");

    public bool running = false;
    public State state;

    construct {
        application_id = "com.github.philip-scott.notes-up";
        program_name = PROGRAM_NAME;
        exec_name = TERMINAL_NAME;
        app_launcher = "com.github.philip-scott.notes-up";

        build_version = Constants.VERSION;
        state = new State ();
    }

    public override void activate () {
        if (!running) {
            ENotes.app = this;
            settings = ENotes.Services.Settings.get_instance ();

            var notes_path = Path.build_filename (GLib.Environment.get_home_dir (), "/.local/share/notes-up/");
            var notes_dir = File.new_for_path (notes_path);

            if (!notes_dir.query_exists ()) {
                DirUtils.create_with_parents (notes_path, 0766);
            }

            if (settings.notes_database == "") { // Init databases
                settings.notes_database = Path.build_filename (notes_path, "NotesUp.db");
            }

            ENotes.NOTES_DIR = settings.notes_location;
            ENotes.NOTES_DB = settings.notes_database;

            if (settings.import_files) {
                FileManager.import_files ();

                if (NotebookTable.get_instance ().get_notebooks ().size == 0) {
                    NotebookTable.get_instance ().new_notebook (0, _("New Notebook"), {0.7, 0, 0}, "", "");
                }
            }

            var window = new ENotes.Window (this);
            this.add_window (window);

            running = true;

            weak Gtk.IconTheme default_theme = Gtk.IconTheme.get_default ();
            default_theme.add_resource_path ("/com/github/philip-scott/notes-up/icons/");
        }

        get_app_window ().show_app ();
    }

    public ENotes.Window get_app_window () {
        return active_window as ENotes.Window;
    }

    // Dummy class that holds the current app state so other elements can interact with it
    public class State : Object {
        public signal void update_page_title ();

        public ENotes.Page? opened_page { get; private set; }

        public ENotes.Notebook? opened_page_notebook { get; private set;  }
        public ENotes.Notebook? opened_notebook { get; set; }

        public ENotes.Mode mode { get; set; default = ENotes.Mode.NONE; }
        public bool show_page_info { get; set; }

        public string style_scheme { get; private set; }

        // Search items
        public signal void search_selected ();
        public string search_field { get; set; default = ""; }

        // Bookmarking
        public signal void bookmark_changed ();

        // Page state changed
        public signal void request_saving_page_info ();
        public signal void page_updated ();
        public signal void page_deleted ();

        // Notebook state changed
        public signal void opened_notebook_updated ();
        public signal void load_all_pages ();
        public signal void notebook_contents_changed ();

        // Tags Changed
        public signal void tags_changed ();

        // Show pages by:
        public signal void show_all_pages ();
        public signal void show_pages_in_tag (Tag tag);

        // Editor
        public signal void reload_editor_settings ();
        public string editor_font { get; set; default = ""; }
        public string editor_scheme { get; set; default = "classic"; }
        public bool editor_show_line_numbers { get; set; }
        public bool editor_auto_indent { get; set; }

        construct {
            notify.connect ((spec) => {
                debug ("Property changed in state: %s\n", spec.name);
            });
        }

        public void open_notebook (int64 notebook_id) {
            if (notebook_id != 0) {
                opened_notebook = NotebookTable.get_instance ().load_notebook_data (notebook_id);
            } else {
                load_all_pages ();
            }
        }

        public void open_page (int64 page_id) {
            request_saving_page_info ();
            var page_to_open = PageTable.get_instance ().get_page (page_id);

            if (page_to_open == null) return;

            if (opened_page_notebook == null || opened_page_notebook.id != page_to_open.notebook_id) {
                opened_page_notebook = NotebookTable.get_instance ().load_notebook_data (page_to_open.notebook_id);
            }

            opened_page = page_to_open;
            app.state.update_page_title ();
        }

        public void save_opened_page () {
            if (opened_page == null) return;

            PageTable.get_instance ().save_page (opened_page);
            update_page_title ();
            page_updated ();
        }

        public void set_style (string style) {
            var gtk_settings = Gtk.Settings.get_default ();

            switch (style) {
                case "solarized-light":
                    style_scheme = style;
                    editor_scheme = style;
                    gtk_settings.gtk_application_prefer_dark_theme = false;
                    break;
                case "solarized-dark":
                    style_scheme = style;
                    editor_scheme = style;
                    gtk_settings.gtk_application_prefer_dark_theme = true;
                    break;
                default:
                    style_scheme = "high-contrast";
                    editor_scheme = "classic";
                    gtk_settings.gtk_application_prefer_dark_theme = false;
                    break;
            }

            reload_editor_settings ();
        }

        public void toggle_app_mode () {
            if (mode == ENotes.Mode.EDIT) {
                mode = ENotes.Mode.VIEW;
            } else {
                mode = ENotes.Mode.EDIT;
            }
        }
    }
}
