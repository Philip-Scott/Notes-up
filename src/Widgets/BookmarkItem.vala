/*
 * Bookmarks will be syslinks to the bookmarked file
 * */

public class ENotes.BookmarkItem : ENotes.SidebarItem {
    public ENotes.Notebook parent_notebook { public get; private set; }
    public ENotes.Page page { public get; private set; }
    private File bookmark_file;

    private Gtk.Menu menu;
    private Gtk.MenuItem remove_item;

    public BookmarkItem (string bookmark_file) {
        this.bookmark_file = File.new_for_path (ENotes.NOTES_DIR + bookmark_file);

        try {
            string target = this.bookmark_file.query_info (FileAttribute.STANDARD_NAME + "," + FileAttribute.STANDARD_SYMLINK_TARGET, 0).get_symlink_target ();
            page = new ENotes.Page (target);
        } catch (Error e) {

        }

        this.parent_notebook = new ENotes.Notebook (page.path);
        this.name = page.name;
        set_color (parent_notebook);

        setup_menu ();
    }

    private void setup_menu () {
        menu = new Gtk.Menu ();
        remove_item = new Gtk.MenuItem.with_label (_("Remove"));
        menu.add (remove_item);
        menu.show_all ();
    }

    public override Gtk.Menu? get_context_menu () {
        return menu;
    }
}
