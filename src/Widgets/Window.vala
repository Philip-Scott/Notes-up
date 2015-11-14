public class ENotes.Window : Gtk.ApplicationWindow {
    
    private Gtk.Paned pane1;
    private Gtk.Paned pane2;

    protected override bool delete_event (Gdk.EventAny event) {
	    int width;
	    int height;
	    int x;
		int y;
		
		editor.save_file ();
		get_size (out width, out height);
		get_position (out x, out y);
		
		settings.pos_x = x;
		settings.pos_y = y;
		settings.panel_size = pane1.position;
		settings.window_width = width;
		settings.window_height = height;
		settings.mode = headerbar.get_mode ();
		
		this.destroy ();
		return true;
	}

	private void load_settings () {
		string notebook = settings.last_folder;
		
		resize (settings.window_width, settings.window_height);		
		
		pane1.position = settings.panel_size;
		pages_list.load_pages (notebook);
		headerbar.set_app_mode (settings.mode);
		
		string path = settings.page_path;
		string name = settings.page_name;
		
		if (path != "" && name != "")
			editor.load_file (path, name, true);
	}

    public Window (Gtk.Application app) {
		Object (application: app);

	    build_ui ();
        connect_signals ();       
        load_settings ();
    }

    private void build_ui () {
        headerbar = new ENotes.Headerbar ();
        set_titlebar (headerbar);

        var main_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        pane1 = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
        pane2 = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
        viewer = new ENotes.Viewer ();
        editor = new ENotes.Editor ();
        sidebar = new ENotes.Sidebar ();
        pages_list = new ENotes.PagesList ();
        file_manager = new ENotes.FileManager ();
        
        view_edit_stack = new Gtk.Stack ();
        view_edit_stack.add_named (editor, "editor");
        view_edit_stack.add_named (viewer, "viewer");

        main_box.add (sidebar);
        main_box.add (pane2);
        pane2.pack2(pane1, false, false);
        pane1.pack1 (pages_list, false, false);
        pane1.pack2 (view_edit_stack, true, false);


		this.move (settings.pos_x, settings.pos_y);
        this.add (main_box); 
		this.show_all ();       
    }

    private void connect_signals () {
        headerbar.mode_changed.connect ((edit) => {
            if (edit) {
                view_edit_stack.set_visible_child_name ("editor");
                sidebar.set_reveal_child (false);
                pane2.set_position (0);
            } else {
                view_edit_stack.set_visible_child_name ("viewer");
                sidebar.set_reveal_child (true);
                viewer.load_string (editor.get_text ());
            }
        });
    }

    public void show_app () {
		show_all ();
		show ();
    	present ();

    	set_focus (editor);
	}
}
