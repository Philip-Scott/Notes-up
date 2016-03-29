public class ENotes.NotebookItem : ENotes.SidebarItem {
    public ENotes.Notebook notebook { public get; private set; }

    private Gtk.Menu menu;
    private Gtk.MenuItem remove_item;
    private Gtk.MenuItem edit_item;
    private Gtk.MenuItem new_item;

    public NotebookItem (ENotes.Notebook notebook) {
        this.notebook = notebook;
        set_color (notebook);

        this.name = notebook.name;

        setup_menu ();
        connect_signals ();
    }

    private void connect_signals () {

    }

    private void setup_menu () {
        menu = new Gtk.Menu ();
        edit_item = new Gtk.MenuItem.with_label (_("Edit Notebook"));
        new_item = new Gtk.MenuItem.with_label (_("New Section"));
        remove_item = new Gtk.MenuItem.with_label (_("Delete Notebook"));
        menu.add (edit_item);
        menu.add (remove_item);
        menu.add (new_item);
        menu.show_all ();

        edit_item.activate.connect (() => {
            new NotebookDialog (this.notebook);
        });

        new_item.activate.connect (() => {
            new NotebookDialog.new_subnotebook (this.notebook);
        });

        remove_item.activate.connect (() => {
            notebook.trash ();
        });

        notebook.destroy.connect (() => {
            this.visible = false;
        });
    }

    public override Gtk.Menu? get_context_menu () {
        return menu;
    }
}

