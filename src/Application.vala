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
    STRIKE;

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

    construct {
        application_id = "com.github.philip-scott.notes-up";
        program_name = PROGRAM_NAME;
        app_years = "2015-2017";
        exec_name = TERMINAL_NAME;
        app_launcher = "com.github.philip-scott.notes-up";

        build_version = Constants.VERSION;
        app_icon = "com.github.philip-scott.notes-up";
        main_url = "https://github.com/Philip-Scott/Notes-up/";
        bug_url = "https://github.com/Philip-Scott/Notes-up/issues";
        help_url = "https://github.com/Philip-Scott/Notes-up/";
        translate_url = "https://github.com/Philip-Scott/Notes-up/tree/master/po";
        about_authors = {"Felipe Escoto <felescoto95@hotmail.com>", null};
        about_translators = _("translator-credits");

        about_license_type = Gtk.License.GPL_3_0;
    }

    public override void activate () {
        if (!running) {
            ENotes.app = this;
            settings = ENotes.Services.Settings.get_instance ();

            if (settings.notes_database == "") { // Init databases
                var notes_dir = GLib.Environment.get_home_dir () + "/.local/share/notes-up/";
                DirUtils.create_with_parents (notes_dir, 0766);
                settings.notes_database = notes_dir + "NotesUp.db";
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
}
