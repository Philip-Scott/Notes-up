public class ENotes.NotebookItem : ENotes.SidebarItem {
    public ENotes.Notebook notebook { public get; private set; }

    private Gtk.Menu menu;
    private Gtk.MenuItem edit_item;

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
        edit_item = new Gtk.MenuItem.with_label (_("Edit"));
        menu.add (edit_item);
        menu.show_all ();

        edit_item.activate.connect (() => {
            new NotebookDialog (notebook);
        });
    }

    public override Gtk.Menu? get_context_menu () {
        return menu;
    }
}

