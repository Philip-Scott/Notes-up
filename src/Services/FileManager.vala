


public class ENotes.Notebook : Object {
    public string name;
    public string path;             // /home/..../notes/Notebook_Name/
    public List<string> page;       // Pagename

    public Notebook (string path_) {
        this.path = path_;
        page = new List<string> ();
    }
}

public class ENotes.FileManager : Object {
    public signal void files_updated ();

    public string current_notebook { get; private set;} //Notebook name (Math)
    public string current_page { get; private set; }    //Page Name     (Multi variable)
    private string file_path;                           //Notebook Path + page name  Page
    private File file = null;

    public FileManager () {

    }

    public ENotes.Notebook? load_notebook (string notebook_name) {
        stderr.printf ("Asking for %s notebook", notebook_name);
        var notebook = new ENotes.Notebook (ENotes.NOTES_DIR + "/" + notebook_name + "/");
        notebook.name = notebook_name;

        try {
            var directory = File.new_for_path (notebook.path);
            var enumerator = directory.enumerate_children (FileAttribute.STANDARD_NAME, 0);
            FileInfo file_info;


            while ((file_info = enumerator.next_file ()) != null) {
                stderr.printf ("Page found %s\n", file_info.get_name ());
                notebook.page.append (file_info.get_name ());
            }

        } catch (Error e) {
            stderr.printf ("Error in Loading Pages: %s   %s\n", current_notebook, e.message);
        }


        return notebook;
    }

    public string load_file (string file_path, string file_name) {
    	//if (save_state) {
        if (file_path != "") settings.page_path = file_path;
	    if (file_name != "") settings.page_name = file_name;
	    //}
    
        stderr.printf ("Requesting file: %s%s", file_path, file_name);
        current_page = file_name;
        this.file_path = file_path;
        file = File.new_for_path (file_path + file_name);

        string data = "";
        if (file.query_exists ()) {
            try {
                //open file
                var dis = new DataInputStream (file.read ());
                size_t size;
                data = dis.read_until ("\0", out size);
            } catch (Error e) {
                error ("Error loading file: %s", e.message);
            }
        }

        return data;
    }

    public void save_file () {
        if (file == null) return;
        string file_name = make_filename ();
        if (file_name == null) return;
        stderr.printf ("Saving file to: %s\n", file_name);

        try {
            if (file.query_exists ()) {
                file.delete ();
            }

            file = File.new_for_path (file_path + file_name);
            var dos = new DataOutputStream (file.create (FileCreateFlags.REPLACE_DESTINATION));

            uint8[] data = editor.get_text ().data;
            long written = 0;
            while (written < data.length) {
                // sum of the bytes of 'text' that already have been written to the stream
                written += dos.write (data[written:data.length]);
            }

            stderr.printf ("File saved\n");
        } catch (Error e) {
            stderr.printf ("%s\n", e.message);
        }

        pages_list.refresh ();
    }

  
    public void export_pdf_action () {
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

    public void write_file (File file, string contents) throws Error {
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
    public void create_file_if_not_exists (File file) throws Error{
        if (!file.query_exists ()) {
            try {
                file.create (FileCreateFlags.REPLACE_DESTINATION);
            } catch (Error e) {
                throw new Error (Quark.from_string (""), -1, "Could not write file: %s", e.message);
            }
        }
    }
    
    private File? get_file_from_user () {
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
    
    private string make_filename () {
        string file_name = editor.get_text ().split ("\n", 2)[0];
        file_name = file_name.replace ("#", "").replace ("\n", "");

        return file_name;
    }
}
