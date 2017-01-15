/*
* Copyright (c) 2015-2016 Felipe Escoto (https://github.com/Philip-Scott/Notes-up)
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

public class ENotes.FileManager : Object {
    private static Gee.HashMap<string, Settings> notebook_settings_cache;

    public static ENotes.Notebook current_notebook;
    public static ENotes.Page current_page { get; private set; }

    // Initial import for previous owners of the app
    public static void import_files () {
        DatabaseTable.init (ENotes.NOTES_DB);

        if (ENotes.NOTES_DIR != "") {
            var directory = File.new_for_path (ENotes.NOTES_DIR);
            if (directory.query_exists ()) {
                load_notebooks (directory, 0);
            }
        }

        ENotes.Services.Settings.get_instance ().import_files = false;
    }

    public static void load_notebooks (File directory, int64 parent_id) {
        try {
            var enumerator = directory.enumerate_children (FileAttribute.STANDARD_NAME, 0);

            FileInfo file_info;
            while ((file_info = enumerator.next_file ()) != null) {
                if (file_info.get_file_type () == FileType.DIRECTORY) {
                    var notebook = parse_notebook (file_info);
                    var id = NotebookTable.get_instance ().new_notebook (parent_id, notebook.name, notebook.rgb, "", "");

                    var new_dir = directory.resolve_relative_path (file_info.get_name ());
                    add_pages_in_notebook (id, new_dir);
                    load_notebooks (new_dir, id);
                }
            }
        } catch (Error e) {
            stderr.printf ("Error: %s\n", e.message);
        }
    }

    public static Notebook parse_notebook (FileInfo file) {
        var notebook = new Notebook ();
        var split = file.get_name ().split ("§", 4);
        notebook.name = split[0].replace (ENotes.NOTES_DIR, "");

        if (split.length > 3) {
            var r = double.parse (split[1]);
            var g = double.parse (split[2]);
            var b = double.parse (split[3]);
            notebook.rgb = {r,g,b};
        }

        return notebook;
    }

    public static void add_pages_in_notebook (int64 id, File directory) {
        try {
            var enumerator = directory.enumerate_children (FileAttribute.STANDARD_NAME, 0);
            FileInfo file_info;

            while ((file_info = enumerator.next_file ()) != null) {
                if (file_info.get_file_type () == FileType.REGULAR) {
                    var file = directory.resolve_relative_path (file_info.get_name ());

                    try {
                        var page = PageTable.get_instance ().new_page (id);

                        var dis = new DataInputStream (file.read ());
                        size_t size;
                        page.data = dis.read_upto ("\0", -1, out size);

                        PageTable.get_instance ().save_page (page);
                    } catch (Error e) {
                        warning ("Error loading file: %s", e.message);
                    }
                }
            }
        } catch (Error e) {
            warning ("Could not load pages: %s",e.message);
        }
    }

    public static List<string> load_bookmarks () {
        var bookmarks = new List<string>();

        CompareDataFunc<string> bookmark_comp = (a, b) => {
            int d = (int) (a.ascii_casecmp  (b));
            return d;
        };

        try {
            var directory = File.new_for_path (ENotes.NOTES_DIR);
            var enumerator = directory.enumerate_children (FileAttribute.STANDARD_NAME + "," + FileAttribute.STANDARD_SYMLINK_TARGET, 0);

            FileInfo file_info;
            while ((file_info = enumerator.next_file ()) != null) {
                if (file_info.get_file_type () != FileType.DIRECTORY) {
                    string temp = file_info.get_name ();
                    bookmarks.insert_sorted_with_data (temp, bookmark_comp);
                }
            }

        } catch (Error e) {
            stderr.printf ("Error: %s\n", e.message);
        }

        return bookmarks;
    }

    public static File? export_pdf_action (string? file_path = null) {
        ENotes.Viewer.get_instance ().load_page (ENotes.Editor.get_instance ().current_page, true);

        File file;
        if (file_path == null) {
            file = get_file_from_user ();
        } else {
            file = File.new_for_path (file_path);
        }

        try { // TODO: we have to write an empty file so we can get file path
            write_file (file, "");
        } catch (Error e) {
            warning ("Could not write initial PDF file: %s", e.message);
            return null;
        }

        var op = new WebKit.PrintOperation (ENotes.Viewer.get_instance ());
        var settings = new Gtk.PrintSettings ();
        settings.set_printer ("Print to File");

        settings[Gtk.PRINT_SETTINGS_OUTPUT_URI] = "file://" + file.get_path ();
        op.set_print_settings (settings);

        op.print ();

        return file;
    }

    public static void write_file (File file, string contents, bool overrite = false) throws Error {
        if (file.query_exists () && overrite) {
            file.delete ();
        }

        create_file_if_not_exists (file);

        file.open_readwrite_async.begin (Priority.DEFAULT, null, (obj, res) => {
            try {
                var iostream = file.open_readwrite_async.end (res);
                var ostream = iostream.output_stream;
                ostream.write_all (contents.data, null);
            } catch (Error e) {
                warning ("Could not write file \"%s\": %s", file.get_basename (), e.message);
            }
        });
    }

    public static void create_file_if_not_exists (File file) throws Error{
        if (!file.query_exists ()) {
            try {
                file.create (FileCreateFlags.REPLACE_DESTINATION);
            } catch (Error e) {
                throw new Error (Quark.from_string (""), -1, "Could not write file: %s", e.message);
            }
        }
    }

    public static File? get_file_from_user (bool save_as_pdf = true) {
        File? result = null;

        string title = "";
        Gtk.FileChooserAction chooser_action = Gtk.FileChooserAction.SAVE;
        string accept_button_label = "";
        List<Gtk.FileFilter> filters = new List<Gtk.FileFilter> ();

        if (save_as_pdf) {
            title =  ("Select destination PDF file");
            chooser_action = Gtk.FileChooserAction.SAVE;
            accept_button_label = ("Save");

            var pdf_filter = new Gtk.FileFilter ();
            pdf_filter.set_filter_name ("PDF File");

            pdf_filter.add_mime_type ("application/pdf");
            pdf_filter.add_pattern ("*.pdf");

            filters.append (pdf_filter);
        } else {
            title =  ("Open file");
            chooser_action = Gtk.FileChooserAction.OPEN;
            accept_button_label = ("Open");

            var filter = new Gtk.FileFilter ();
            filter.set_filter_name ("Images");
            filter.add_mime_type ("image/*");

            filters.append (filter);
        }

        var all_filter = new Gtk.FileFilter ();
        all_filter.set_filter_name ("All Files");
        all_filter.add_pattern ("*");

        filters.append (all_filter);

        var dialog = new Gtk.FileChooserDialog (
            title,
            window,
            chooser_action,
            ("Cancel"), Gtk.ResponseType.CANCEL,
            accept_button_label, Gtk.ResponseType.ACCEPT);


        filters.@foreach ((filter) => {
            dialog.add_filter (filter);
        });

        if (dialog.run () == Gtk.ResponseType.ACCEPT) {
            result = dialog.get_file ();
        }

        dialog.close ();

        return result;
    }

    public static Settings get_settings (string notebook_path, string CHILD_SCHEMA_ID, string CHILD_PATH) {
        var notebook_id = notebook_path.replace (NOTES_DIR, "").replace ("/", "") + "/";

        if (notebook_settings_cache == null) {
            notebook_settings_cache = new Gee.HashMap<string, Settings> ();
        }

        Settings? notebook_settings = notebook_settings_cache.get (notebook_id);

        if (notebook_settings == null) {
            var schema = SettingsSchemaSource.get_default ().lookup (CHILD_SCHEMA_ID, false);
		    if (schema != null) {
			    notebook_settings = new Settings.full (schema, null, CHILD_PATH.printf (notebook_id));
			    notebook_settings_cache.set (notebook_id, notebook_settings);
                notebook_settings = new Settings.full (SettingsSchemaSource.get_default ().lookup (CHILD_SCHEMA_ID, true), null, CHILD_PATH.printf (notebook_id));
            } else {
                warning ("Getting notebook schema failed");
            }
        }

        return notebook_settings;
    }
}
