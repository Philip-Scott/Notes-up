namespace ENotes {
    public string NOTES_DIR;
    
    public ENotes.FileManager file_manager; 
    public ENotes.Window window; 
    public ENotes.Headerbar headerbar;
    public Gtk.Stack view_edit_stack;
    public ENotes.Sidebar sidebar;
    public ENotes.PagesList pages_list;
    public ENotes.Viewer viewer;
    public ENotes.Editor editor;
}

public class ENotes.Application : Gtk.Application {
    /**
     * Translatable launcher (.desktop) strings to be added to template (.pot) file.
     * These strings should reflect any changes in these launcher keys in .desktop file
     */

    public const string PROGRAM_NAME = N_("Notes");

    public const string COMMENT = N_("Your Markdown Notebook.");
    public const string ABOUT_STOCK = N_("About Notes");

    public bool running = false;
    
    public Application () {
        Object (application_id: "org.felipe.enotes");
        ENotes.NOTES_DIR = GLib.Environment.get_home_dir () + "/notes";
    }

    public override void activate () {
        if (!running) {
            window = new ENotes.Window (this);
            this.add_window (window);
            running = true;
        }
        
        window.show_app (); 
    }
}

  
