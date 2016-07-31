public class ENotes.TrashItem : ENotes.SidebarItem {
    public ENotes.Notebook? parent_notebook = null;

    public ENotes.Page? trashed_page = null;
    public ENotes.Notebook? trashed_notebook = null;

    private ENotes.Bookmark bookmark;

    private Gtk.Menu menu;
    private Gtk.MenuItem recover_item;

    public TrashItem.page (Page page) {
        this.bookmark = new Bookmark.from_link (ENotes.NOTES_DIR + bookmark_file);
        this.name = bookmark.page.name;
        this.parent_notebook = new ENotes.Notebook (bookmark.page.path);

        set_color (parent_notebook);

        setup_menu ();
        connect_signals ();
    }

    public TrashItem.notebook (string bookmark_file) {
        this.bookmark = new Bookmark.from_link (ENotes.NOTES_DIR + bookmark_file);
        this.name = bookmark.page.name;
        this.parent_notebook = new ENotes.Notebook (bookmark.page.path);

        set_color (parent_notebook);

        setup_menu ();
        connect_signals ();
    }

    public ENotes.Page get_page () {
        return bookmark.page;
    }

    private void connect_signals () {
        bookmark.destroy.connect (() => {
            this.visible = false;
        });
    }

    private void setup_menu () {
        menu = new Gtk.Menu ();
        remove_item = new Gtk.MenuItem.with_label (_("Restore"));
        remove_item.activate.connect (() => {
            this.bookmark.unbookmark ();
            ENotes.BookmarkButton.get_instance ().setup ();
        });

        menu.add (remove_item);
        menu.show_all ();
    }

    public override Gtk.Menu? get_context_menu () {
        return menu;
    }
}
