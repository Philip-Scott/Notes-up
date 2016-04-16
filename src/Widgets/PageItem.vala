public class ENotes.PageItem : Gtk.ListBoxRow {
    public ENotes.Page page;

    private Gtk.Grid grid;
    private Gtk.Label line1;
    private Gtk.Label line2;

    public PageItem (ENotes.Page page) {
        this.page = page;
        build_ui ();
        connect_page ();
    }

    private void build_ui () {
        set_activatable (true);

        grid = new Gtk.Grid ();
        grid.orientation = Gtk.Orientation.VERTICAL;

        line1 = new Gtk.Label ("");
        line1.use_markup = true;
        line1.halign = Gtk.Align.START;
        line1.get_style_context ().add_class ("h3");
        line1.ellipsize = Pango.EllipsizeMode.END;
        ((Gtk.Misc) line1).xalign = 0;
        line1.margin_top = 4;
        line1.margin_left = 8;
        line1.margin_bottom = 4;

        line2 = new Gtk.Label ("");
        line2.halign = Gtk.Align.START;
        line2.margin_left = 8;
        line2.margin_bottom = 4;
        line2.set_line_wrap (true);
        line2.ellipsize = Pango.EllipsizeMode.END;
        ((Gtk.Misc) line2).xalign = 0;
        line2.get_style_context ().add_class (Gtk.STYLE_CLASS_DIM_LABEL);
        line2.lines = 3;

        var separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
        separator.hexpand = true;

        this.add (grid);
        grid.add (line1);
        grid.add (line2);
        grid.add (separator);

        load_data ();
        this.show_all ();
    }

    public void trash_page () {
        page.trash_page ();
    }

    private void connect_page () {
        page.saved_file.connect (() => {
	        load_data ();
        });

        page.destroy.connect (() => {
            this.destroy ();
        });
    }

    private void load_data () {
        this.line2.label = page.subtitle;
        this.line1.label = "<b>" + page.name + "</b>";
    }
}

