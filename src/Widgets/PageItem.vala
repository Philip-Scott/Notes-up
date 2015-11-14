public class ENotes.PageItem : Gtk.ListBoxRow {
    public string file_path { public get; private set; }
    public string file_name { public get; private set; }
    private Gtk.Grid grid;
    private Gtk.Label name;
    private Gtk.Label line2;

    public PageItem (string file_name, string file_path) {
        this.file_path = file_path;
        this.file_name = file_name;
        build_ui ();
        connect_signals ();
    }

    private void build_ui () {
        set_activatable (true);

        grid = new Gtk.Grid ();
        grid.orientation = Gtk.Orientation.VERTICAL;

        name = new Gtk.Label ("<b>" + cut_string(file_name, 50) + "</b>");
        name.use_markup = true;
        name.halign = Gtk.Align.START;
        name.get_style_context ().add_class ("h3");
        name.ellipsize = Pango.EllipsizeMode.END;

        line2 = new Gtk.Label (file_path);
        line2.ellipsize = Pango.EllipsizeMode.END;
        line2.halign = Gtk.Align.START;
        
        this.add (grid);
        grid.add (name);
        //grid.add (line2);

        this.show_all ();
    }

    private string cut_string (string to_cut, int max) {
        if (to_cut.length > max) return to_cut[0:max] + "...";
        return to_cut;
    }

    

    public void trash_page () {
        try {
            var file = File.new_for_path (file_path + file_name);
            file.trash ();
        } catch (Error e) {
            stderr.printf (file_path + file_name);
        
        }
    }

    private void connect_signals () {
        this.activate.connect (() => {
            stderr.printf ("Activate\n");//
        });
    }

    private void load_data () {
        name.label = "";
    }
}

