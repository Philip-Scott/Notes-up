
public class ENotes.FileManager : Object {
    public static ENotes.Notebook current_notebook;
    public static ENotes.Page current_page { get; private set; }

    private FileManager () {}

    public static List<ENotes.Notebook> load_notebooks () {
        var notebooks = new List<ENotes.Notebook>();
        try {
            var directory = File.new_for_path (ENotes.NOTES_DIR);
            if (!directory.query_exists ())
                directory.make_directory_with_parents ();

            var enumerator = directory.enumerate_children (FileAttribute.STANDARD_NAME, 0);

            FileInfo file_info;
            while ((file_info = enumerator.next_file ()) != null) {
                if (file_info.get_file_type () == FileType.DIRECTORY) {
                    var notebook = new ENotes.Notebook (ENotes.NOTES_DIR + file_info.get_name ());
                    notebooks.append (notebook);
                    search_for_subnotebooks (notebook);
                }
            }
        } catch (Error e) {
            stderr.printf ("Error: %s\n", e.message);
        }

        return notebooks;
    }

    public static void search_for_subnotebooks (Notebook notebook) {
        try {
            var directory = notebook.directory;

            var enumerator = directory.enumerate_children (FileAttribute.STANDARD_NAME, 0);

            FileInfo file_info;
            while ((file_info = enumerator.next_file ()) != null) {
                if (file_info.get_file_type () == FileType.DIRECTORY) {
                    var new_notebook = new ENotes.Notebook (notebook.path + file_info.get_name ());
                    notebook.sub_notebooks.append (new_notebook);

                    search_for_subnotebooks (new_notebook);
                }
            }
        } catch (Error e) {
            stderr.printf ("Error: %s\n", e.message);
        }

    }

    public static List<string> load_bookmarks () {
        var bookmarks = new List<string>();

        try {
            var directory = File.new_for_path (ENotes.NOTES_DIR);
            var enumerator = directory.enumerate_children (FileAttribute.STANDARD_NAME + "," + FileAttribute.STANDARD_SYMLINK_TARGET, 0);

            FileInfo file_info;
            while ((file_info = enumerator.next_file ()) != null) {
                if (file_info.get_file_type () != FileType.DIRECTORY) {
                    string temp = file_info.get_name ();
                    bookmarks.append (temp);
                }
            }

        } catch (Error e) {
            stderr.printf ("Error: %s\n", e.message);
        }

        return bookmarks;
    }

    public static void export_pdf_action () {
        var file = get_file_from_user ();

        try { // TODO: we have to write an empty file so we can get file path
            write_file (file, "");
        } catch (Error e) {
            warning ("Could not write initial PDF file: %s", e.message);
            return;
        }

        var op = new WebKit.PrintOperation (viewer);
        var settings = new Gtk.PrintSettings ();
        settings.set_printer ("Print to File");

        settings[Gtk.PRINT_SETTINGS_OUTPUT_URI] = "file://" + file.get_path ();
        op.set_print_settings (settings);

        op.print ();
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

    public static string create_notebook (string name, double r, double g, double b, string source = NOTES_DIR) {
        string notebook_name = "%s§%.3f§%.3f§%.3f".printf (name,r,g,b);
        var directory = File.new_for_path (source + notebook_name);
        try {
            directory.make_directory_with_parents ();
        } catch (Error e) {
            stderr.printf ("Notebook not created: %s", e.message);
        }
        return notebook_name;
    }

    private static File? get_file_from_user () {
        File? result = null;

        string title = "";
        Gtk.FileChooserAction chooser_action = Gtk.FileChooserAction.SAVE;
        string accept_button_label = "";
        List<Gtk.FileFilter> filters = new List<Gtk.FileFilter> ();


        title =  ("Select destination PDF file");
        chooser_action = Gtk.FileChooserAction.SAVE;
        accept_button_label = ("Save");

        var pdf_filter = new Gtk.FileFilter ();
        pdf_filter.set_filter_name ("PDF File");

        pdf_filter.add_mime_type ("application/pdf");
        pdf_filter.add_pattern ("*.pdf");

        filters.append (pdf_filter);

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
}
