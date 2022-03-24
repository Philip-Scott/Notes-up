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
    PAGE_INFO,
    PANEL_MODE,
    PANEL_MODE_R;

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
            case PANEL_MODE:    return _("<Ctrl>P");
            case PANEL_MODE_R:  return _("<Ctrl><Shift>P");
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
}

namespace ENotes.FeatureFlags {
    public const bool SHOW_NOTEBOOK_PANE = false;
}

public class ENotes.Application : Granite.Application {
    public const string PROGRAM_NAME = N_("Notes-Up");
    public const string COMMENT = N_("Your Markdown Notebook.");
    public const string ABOUT_STOCK = N_("About Notes");

    public bool running = false;
    public State state;

    construct {
        flags |= ApplicationFlags.HANDLES_OPEN;

        application_id = Constants.PROJECT_NAME;
        program_name = PROGRAM_NAME;
        exec_name = Constants.PROJECT_NAME;
        app_launcher = Constants.PROJECT_NAME;

        state = new State ();
    }

    private void init () {
        if (!running) {
            ENotes.app = this;
            settings = ENotes.Services.Settings.get_instance ();

            // If app has never being used, open default DB.
            if (settings.notes_database == "") {
                var notes_path = Path.build_filename (GLib.Environment.get_home_dir (), "/.local/share/notes-up/");

                settings.notes_database = Path.build_filename (notes_path, "NotesUp.db");
            }

            weak Gtk.IconTheme default_theme = Gtk.IconTheme.get_default ();
            default_theme.add_resource_path ("/com/github/philip-scott/notes-up/icons/");
        }
    }

    public override void activate () {
        init ();
        state.set_database (ENotes.Services.Settings.get_instance ().notes_database);
        start_window ();
    }

    public override void open (File[] files, string hint) {
        if (files.length > 1) {
            warning ("Only the first file will be opened");
        }

        // Close current file if running.
        if (!running) {
            init ();
        }

        state.set_database (files[0].get_path ());

        start_window ();
    }

    private void start_window () {
        if (!running) {
            var window = new ENotes.Window (this);
            this.add_window (window);

            running = true;
        }

        get_app_window ().show_app ();
    }

    public ENotes.Window get_app_window () {
        return active_window as ENotes.Window;
    }

    // Dummy class that holds the current app state so other elements can interact with it
    public class State : Object {
        // Database
        public string? db { get; private set; }
        public signal void pre_database_change (); // Called before the database closes
        public signal void post_database_change (); // Called after a new database has initiated

        public signal void update_page_title ();

        public ENotes.Page? opened_page { get; private set; }

        public ENotes.Notebook? opened_page_notebook { get; private set;  }
        public ENotes.Notebook? opened_notebook { get; set; }

        public ENotes.Mode mode { get; set; default = ENotes.Mode.NONE; }
        public bool show_page_info { get; set; }

        public int panes_visible { get; set; default = -1; }

        public string style_scheme { get; private set; }

        // Search items
        public signal void search_selected ();
        public string search_field { get; set; default = ""; }

        // Bookmarking
        public signal void bookmark_changed ();

        // Page state changed
        public signal void request_saving_page_info ();
        public signal void page_text_updated (); // Used to weakly update the viewer
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

        // FileData
        public signal void file_data_changed (FileDataType type, string value);

        construct {
            notify.connect ((spec) => {
                debug ("Property changed in state: %s\n", spec.name);
            });
        }

        public void set_database (string _db) {
            if (db == _db) return;

            if (!Db.is_file_valid (_db)) {
                return;
            }

            pre_database_change ();
            DatabaseTable.terminate ();

            db = _db;

            opened_page_notebook = null;
            opened_notebook = null;
            opened_page = null;

            DatabaseTable.init (db);

            var recent_files = new GLib.Array<string>();
            recent_files.append_val (_db);

            foreach (var file in settings.recent_files) {
                if (file == _db) continue;
                recent_files.append_val (file);
            }

            settings.recent_files = recent_files.data;
            settings.notes_database = _db;

            post_database_change ();
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
            opened_page.cache_changed = false;

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
