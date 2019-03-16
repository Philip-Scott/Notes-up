/*
* Copyright (c) 2011-2016 Felipe Escoto (https://github.com/Philip-Scott/Notes-up)
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
    public ENotes.Window window;
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

            window = new ENotes.Window (this);
            this.add_window (window);

            running = true;
        }

        window.show_app ();
    }

    // Dummy class that holds the current app state so other elements can interact with it
    public class State : Object {
        public signal void update_page_title ();

        public ENotes.Page? opened_page { get; set; }

        public ENotes.Notebook? opened_page_notebook { get; set;  }
        public ENotes.Notebook? opened_notebook { get; set; }

        public ENotes.Mode mode { get; set; default = ENotes.Mode.NONE; }
        public bool show_page_info { get; set; }

        // Search items
        public signal void search_selected ();
        public string search_field { get; set; default = ""; }

        // Bookmarking
        public signal void bookmark_changed ();

        // Page state changed
        public signal void page_updated ();
        public signal void page_deleted ();

        // Notebook state changed
        public signal void opened_notebook_updated ();
        public signal void load_all_pages ();

        construct {
            notify.connect ((spec) => {
                print ("Property changed in state: %s\n", spec.name);
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
            print ("Open page %lld\n", page_id);
            opened_page = PageTable.get_instance ().get_page (page_id);
        }
    }
}
