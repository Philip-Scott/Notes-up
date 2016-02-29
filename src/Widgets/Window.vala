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
		settings.panel_size = pane2.position;
		settings.window_width = width;
		settings.window_height = height;
		settings.mode = headerbar.get_mode ();
		settings.last_folder = pages_list.current_notebook.path;
		settings.page_path = editor.current_page.full_path;

		return false;
	}

	private void load_settings () {
        resize (settings.window_width, settings.window_height);
		pane2.position = settings.panel_size;

		headerbar.set_mode (settings.mode);

	    if (settings.last_folder != "") {
		    var notebook = new ENotes.Notebook (settings.last_folder);
		    notebook.refresh ();

		    pages_list.load_pages (notebook);
		    sidebar.select_notebook (notebook.name);
		}

		string path = settings.page_path;
		
		if (path != "") {
		    var page = new ENotes.Page (path);

		    if (!page.new_page)
			    editor.load_file (page);
		}
	}

    public Window (Gtk.Application app) {
		Object (application: app);

	    build_ui ();
        connect_signals (app);
        load_settings ();
        sidebar.first_start ();
    }

    private void build_ui () {
        headerbar = new ENotes.Headerbar ();
        set_titlebar (headerbar);

        pane1 = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
        pane2 = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
        viewer = new ENotes.Viewer ();
        editor = new ENotes.Editor ();
        sidebar = new ENotes.Sidebar ();
        pages_list = new ENotes.PagesList ();

        view_edit_stack = new Gtk.Stack ();
        view_edit_stack.add_named (editor, "editor");
        view_edit_stack.add_named (viewer, "viewer");

        pane1.pack1 (sidebar, false, false);
        pane1.pack2 (pane2, true, false);
        pane2.pack1 (pages_list, false, false);
        pane2.pack2 (view_edit_stack, true, false);
		pane1.position = (50);

		this.move (settings.pos_x, settings.pos_y);
        this.add (pane1);
		this.show_all ();
    }

    private void connect_signals (Gtk.Application app) {
        var change_mode = new SimpleAction ("change-mode", null);
        change_mode.activate.connect (toggle_edit);
        add_action (change_mode);
        app.set_accels_for_action ("win.change-mode", {"<Ctrl>M"});

        var save_action = new SimpleAction ("save", null);
        save_action.activate.connect (save);
        add_action (save_action);
        app.set_accels_for_action ("win.save", {"<Ctrl>S"});

        var close_action = new SimpleAction ("close-action", null);
        close_action.activate.connect (request_close);
        add_action (close_action);
        app.set_accels_for_action ("win.close-action", {"<Ctrl>Q"});

        var new_action = new SimpleAction ("new-action", null);
        new_action.activate.connect (new_page);
        add_action (new_action);
        app.set_accels_for_action ("win.new-action", {"<Ctrl>N"});

        headerbar.mode_changed.connect ((edit) => {
            if (edit) {
                view_edit_stack.set_visible_child_name ("editor");
                sidebar.visible = (false);
                pane2.set_position (0);
            } else {
                sidebar.visible = (true);
                view_edit_stack.set_visible_child_name ("viewer");
                viewer.load_string (editor.get_text ());
            }
        });
    }

    private void new_page () {
        pages_list.new_blank_page ();
    }

    private void request_close () {
        close ();
    }

    private void save () {
        editor.save_file ();
    }

    private void toggle_edit () {
        int mode = headerbar.get_mode ();

        if (mode == 1) {
            mode = 0;
        } else {
            mode = 1;
        }

        headerbar.set_mode (mode);
    }

    public void show_app () {
		show ();
    	present ();

    	set_focus (editor);
	}
}
