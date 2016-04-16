



public class ENotes.BookmarkButton : Gtk.Button {
    private ENotes.Page current_page;
    private Bookmark bookmark;
    private  Gtk.Image pic;

    private int size = 42;

    public BookmarkButton () {
        pic = new Gtk.Image.from_icon_name ("non-starred",  Gtk.IconSize.LARGE_TOOLBAR);

        this.image = pic;

        expand = false;
        can_focus = false;

        has_tooltip = true;
        tooltip_text = _("Bookmark page");

        connect_signals ();
    }

    public void set_page (ENotes.Page page) {
        this.current_page = page;
        setup ();
    }

    public void setup () {
        if (this.current_page.is_bookmarked ()) {
            pic.set_from_icon_name ("starred", Gtk.IconSize.DIALOG);
        } else {
            pic.set_from_icon_name ("non-starred", Gtk.IconSize.DIALOG);
        }
    }

    public void main_action () {
        this.bookmark = new ENotes.Bookmark.from_page (current_page);

        if (!this.current_page.is_bookmarked ()) {
            this.bookmark.bookmark ();
        } else {
            this.bookmark.unbookmark ();
        }

        sidebar.load_bookmarks ();
        setup ();
    }

    private void connect_signals () {
        this.clicked.connect (() => {
            main_action ();
        });
    }
}
