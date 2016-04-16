
public class ENotes.Bookmark : Object {
    public signal void destroy ();

    public string name;
    private string link;

    public ENotes.Page page { public get; private set; }
    private File bookmark_file;

    public Bookmark.from_link (string link) {
        this.link = link;

        setup (link);
    }

    public Bookmark.from_page (ENotes.Page page) {
        this.page = page;

        link = ENotes.NOTES_DIR + page.full_path.replace (ENotes.NOTES_DIR, "").replace ("/", ".");
        setup (link);
    }

    private void setup (string link) {
        this.bookmark_file = File.new_for_path (link);

        try {
            string target = this.bookmark_file.query_info (FileAttribute.STANDARD_NAME + "," + FileAttribute.STANDARD_SYMLINK_TARGET, 0).get_symlink_target ();
            page = new ENotes.Page (target);

            if (page.new_page) return;
        } catch (Error e) {


            return;
        }

        this.name = page.name;
    }

    public void bookmark () {
        FileUtils.symlink (page.full_path, link);
    }

    public void unbookmark () {
        try {
            bookmark_file.@delete ();
        } catch (Error e) {
            stderr.printf ("Could not dellete bookmark: %s", e.message);
        }

        destroy ();
    }
}
