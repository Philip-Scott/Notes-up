public class ENotes.PagesList : Gtk.Box {
    private Gtk.ListBox listbox;
    private Gtk.Box toolbar;

    private Gtk.Separator separator;
    private Gtk.Button minus_button;
    private Gtk.Button plus_button;
    private Gtk.Label notebook_name;
    private Gtk.Label page_total;

    public ENotes.Notebook current_notebook;

    public PagesList () {
        build_ui ();
        connect_signals ();
    }

    private void build_ui () {
        orientation = Gtk.Orientation.VERTICAL;

        var scroll_box = new Gtk.ScrolledWindow (null, null);
        listbox = new Gtk.ListBox ();
        listbox.set_size_request (200,250);
        scroll_box.set_size_request (200,250);
        listbox.vexpand = true;
        toolbar = build_toolbar ();

        scroll_box.add (listbox);
        this.add (scroll_box);
        this.add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
        this.add (toolbar);
    }

    private Gtk.Box build_toolbar () {
        var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);

        plus_button = new Gtk.Button.with_label ("+");
        minus_button = new Gtk.Button.with_label ("-");
        notebook_name = new Gtk.Label ("");
        page_total = new Gtk.Label ("");
        separator = new Gtk.Separator (Gtk.Orientation.VERTICAL);

        minus_button.get_style_context ().add_class ("flat");
        plus_button.get_style_context ().add_class ("flat");

        notebook_name.halign = Gtk.Align.START;
        page_total.halign = Gtk.Align.END;
        minus_button.halign = Gtk.Align.END;
        minus_button.visible = false;
        separator.visible = false;
        notebook_name.hexpand = true;
        minus_button.can_focus = false;
        plus_button.can_focus = false;

        notebook_name.margin = 4;
        page_total.margin = 4;

        box.add (notebook_name);
        box.add (page_total);
        box.add (new Gtk.Separator (Gtk.Orientation.VERTICAL));
        box.add (minus_button);
        box.add (separator);
        box.add (plus_button);
        box.set_sensitive (false);
        box.show_all ();
        return box;
    }

    public void clear_pages () {
    	listbox.unselect_all ();
        var childerns = listbox.get_children ();

        foreach (Gtk.Widget child in childerns) {
        	if (child is Gtk.ListBoxRow)
            	listbox.remove (child);
        }
    }

    private void refresh () {
    	current_notebook.refresh ();
        load_pages (current_notebook);
    }

    public void load_pages (ENotes.Notebook notebook) {
        clear_pages ();
        this.current_notebook = notebook;
        notebook.refresh ();

        foreach (ENotes.Page page in notebook.pages) {
            new_page (page);
        }

        bool has_pages = notebook.pages.length () > 0;

        if (!has_pages) {
            new_blank_page ();
        }

        toolbar.set_sensitive (true);
        page_total.label = @"$(notebook.pages.length ()) Pages";
        this.notebook_name.label = notebook.name.split ("§")[0] + ":";
        listbox.show_all ();
    }

    private ENotes.PageItem new_page (ENotes.Page page) {
        var page_box = new ENotes.PageItem (page);
        listbox.add (page_box);

        return page_box;
    }

    public void new_blank_page () {
        editor.save_file ();
        var page = current_notebook.add_page_from_name (_("New Page"));
        page.new_page = true;

        var page_item = new ENotes.PageItem (page);

        editor.load_file (page);
        listbox.prepend (page_item);
        listbox.show_all ();
    }

    private void connect_signals () {
        headerbar.mode_changed.connect ((edit) => {
            minus_button.visible = edit;
            separator.visible = edit;
            page_total.visible = !edit;
        });

        plus_button.clicked.connect (() => {
            new_blank_page ();
        });

        minus_button.clicked.connect (() => {
            editor.set_sensitive (false);
            editor.reset (false);
            headerbar.set_title (null);
            var row = listbox.get_selected_row ();
            ((ENotes.PageItem) row).trash_page ();
            refresh ();
        });

        listbox.row_selected.connect ((row) => {
            if (row == null) return;
            editor.load_file (((ENotes.PageItem) row).page);
        });
    }
}
