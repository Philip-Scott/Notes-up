public class ENotes.TrashItem : ENotes.SidebarItem {
    public ENotes.Notebook? parent_notebook = null;

    public ENotes.Page? trashed_page = null;
    public ENotes.Notebook? trashed_notebook = null;

    private Gtk.Menu menu;
    private Gtk.MenuItem restore_item;

    construct {
        selectable = false;
        setup_menu ();
    }

    public TrashItem.page (Page page) {
        this.trashed_page = page;
        this.name = page.name;
    }

    public TrashItem.notebook (Notebook notebook) {
        this.trashed_notebook = notebook;
        this.name = notebook.name;
        set_color (notebook.rgb);
    }

    private void setup_menu () {
        menu = new Gtk.Menu ();
        restore_item = new Gtk.MenuItem.with_label (_("Restore"));
        restore_item.activate.connect (() => {
            if (trashed_page != null) {
                Trash.get_instance ().restore_page (trashed_page);
                PagesList.get_instance ().refresh ();
            } else if (trashed_notebook != null){
                Trash.get_instance ().restore_notebook (trashed_notebook);
            }

            visible = false;
        });

        menu.add (restore_item);
        menu.show_all ();
    }

    public override Gtk.Menu? get_context_menu () {
        return menu;
    }
}
