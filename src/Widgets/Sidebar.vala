public class ENotes.Sidebar : Gtk.Revealer {
    private Gtk.Grid main_grid;
    private Gtk.Grid notebook_grid;

    public Sidebar () {
        build_ui ();
        load_notebooks ();
    }

    private void build_ui () {
        set_transition_type (Gtk.RevealerTransitionType.SLIDE_RIGHT);

        main_grid = new Gtk.Grid ();
        var grid = new Gtk.Grid ();
        main_grid.orientation = Gtk.Orientation.VERTICAL;
        grid.orientation = Gtk.Orientation.HORIZONTAL;

        notebook_grid = new Gtk.Grid ();
        notebook_grid.valign = Gtk.Align.START;
        notebook_grid.orientation = Gtk.Orientation.VERTICAL;
        
        var notebook_label = new Gtk.Label ("Notebooks");
        notebook_label.get_style_context ().add_class ("h4");
        notebook_label.halign = Gtk.Align.START;
        notebook_label.valign = Gtk.Align.START;
        notebook_label.margin_start = 8;
        
        var separator = new Gtk.Separator (Gtk.Orientation.VERTICAL);
        separator.vexpand = true;
        
        main_grid.add (notebook_label);
        main_grid.add (notebook_grid);
        
        grid.add (main_grid);
        grid.add (separator);
        this.add (grid);
    }

    //NotebookName§Color
    
    private void clear_pages () {
        var childerns = notebook_grid.get_children ();

        foreach (Gtk.Widget child in childerns) {
            notebook_grid.remove (child);
        }
    }
    
    public void load_notebooks () {
        clear_pages ();
        try {
            var directory = File.new_for_path (ENotes.NOTES_DIR);
            var enumerator = directory.enumerate_children (FileAttribute.STANDARD_NAME, 0);

            FileInfo file_info;
            while ((file_info = enumerator.next_file ()) != null) {
                var notebook = new NotebookItem (file_info.get_name ());

                notebook_grid.add (notebook);
            }

        } catch (Error e) {
            stderr.printf ("Error: %s\n", e.message);
        }
    }
}
