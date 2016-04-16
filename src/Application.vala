
namespace ENotes {
    public ENotes.Headerbar headerbar;
    public ENotes.BookmarkButton bookmark_button;
    public ENotes.ViewEditStack view_edit_stack;
    public ENotes.Sidebar sidebar;
    public ENotes.PagesList pages_list;
    public ENotes.Viewer viewer;
    public ENotes.Editor editor;
    public ENotes.Services.Settings settings;
    public ENotes.Window window;
    public string NOTES_DIR;
}

public class ENotes.Application : Gtk.Application {
    public const string PROGRAM_NAME = N_("Notes-up");
    public const string COMMENT = N_("Your Markdown Notebook.");
    public const string ABOUT_STOCK = N_("About Notes");

    public bool running = false;
    
    public Application () {
        Object (application_id: "org.notes");
    }

    public override void activate () {
        if (!running) {
            settings = new ENotes.Services.Settings ();
            if (settings.notes_location == "") {
                settings.notes_location = GLib.Environment.get_home_dir () + "/.notes/";
            }

	        ENotes.NOTES_DIR = settings.notes_location;

            window = new ENotes.Window (this);
            this.add_window (window);

            running = true;
        }
        window.show_app (); 
    }
}
