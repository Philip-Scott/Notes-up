public class ENotes.PagesList : Gtk.Box {
    private Gtk.ListBox listbox;
    private Gtk.Box toolbar;

    private Gtk.Button minus_button;
    private Gtk.Button plus_button;
    private Gtk.Label notebook_name;
    private Gtk.Label page_total;

    private ENotes.Notebook current_notebook;

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

        notebook_name.halign = Gtk.Align.START;
        page_total.halign = Gtk.Align.END;
        minus_button.halign = Gtk.Align.END;
        minus_button.visible = false;
        page_total.hexpand = true;
        minus_button.can_focus = false;
        plus_button.can_focus = false;

        notebook_name.margin = 4;
        page_total.margin = 4;

        //box.add (plus_button);
        box.add (notebook_name);
        box.add (page_total);
        box.add (minus_button);
        box.set_sensitive (false);
        return box;
    }

    public void clear_pages () {
        var childerns = listbox.get_children ();

        foreach (Gtk.Widget child in childerns) {
            listbox.remove (child);
        }
    }

    public void refresh () {
        load_pages (current_notebook.name);
    }

    public void load_pages (string notebook_name) {
        stderr.printf ("Notebook %s requested\n", notebook_name);
        clear_pages ();
        current_notebook = file_manager.load_notebook (notebook_name);

        foreach (string page in current_notebook.page) {
            new_page (page, current_notebook.path);
        }

        new_page ("New Page", current_notebook.path);
        
        toolbar.set_sensitive (true);
        page_total.label = @"$(current_notebook.page.length ()) Pages";
        this.notebook_name.label = current_notebook.name.split ("§")[0] + ":";
        listbox.show_all ();
    }

    private Gtk.ListBoxRow new_page (string file_name, string file_path) {
        var page = new ENotes.PageItem (file_name, file_path);

        var separator = new Gtk.ListBoxRow ();
        separator.add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
        separator.selectable = false;
        separator.activatable = false;

        listbox.add (page);
        listbox.add (separator);

        return page;
    }

    private void connect_signals () {
        headerbar.mode_changed.connect ((edit) => {
            if (edit) {
                minus_button.visible = true;
            } else {
                minus_button.visible = false;
            }
        });

        plus_button.clicked.connect (() => {
            editor.save_file ();
            refresh ();
            var page = new_page ("New Page", current_notebook.path);
            listbox.row_selected (page);
        });

        minus_button.clicked.connect (() => {
            editor.reset (false);
            var row = listbox.get_selected_row ();
            ((ENotes.PageItem) row).trash_page ();
            refresh ();
        });

        listbox.row_selected.connect ((row) => {
            ((ENotes.PageItem) row).request_page ();
        });
    }
}
