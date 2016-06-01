/*
* Copyright (c) 2011-2016 Felipe Escoto (https://github.com/Philip-Scott/Notes-up)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 59 Temple Place - Suite 330,
* Boston, MA 02111-1307, USA.
*
* Authored by: Felipe Escoto <felescoto95@hotmail.com>
*/

public class ENotes.Window : Gtk.ApplicationWindow {
    private ENotes.BookmarkButton bookmark_button;
    private ENotes.Editor editor;
    private ENotes.Headerbar headerbar;
    private ENotes.PagesList pages_list;
    private ENotes.Sidebar sidebar;
    private ENotes.ViewEditStack view_edit_stack;
    private ENotes.Viewer viewer;

    private Gtk.Paned pane1;
    private Gtk.Paned pane2;

    public Window (Gtk.Application app) {
        Object (application: app);

        build_ui ();
        connect_signals (app);
        load_settings ();
        Sidebar.get_instance ().first_start ();
    }

    private void build_ui () {
        headerbar = ENotes.Headerbar.get_instance ();
        set_titlebar (headerbar);

        set_events (Gdk.EventMask.BUTTON_PRESS_MASK);

        pane1 = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
        pane2 = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
        sidebar = ENotes.Sidebar.get_instance ();
        pages_list = ENotes.PagesList.get_instance ();

        view_edit_stack = ENotes.ViewEditStack.get_instance ();
        editor = ENotes.Editor.get_instance ();
        viewer = ENotes.Viewer.get_instance ();

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

        var find_action = new SimpleAction ("find-action", null);
        find_action.activate.connect (headerbar.show_search);
        add_action (find_action);
        app.set_accels_for_action ("win.find-action", {"<Ctrl>F"});

        var bookmark_action = new SimpleAction ("bookmark-action", null);
        bookmark_action.activate.connect (bookmark_button.main_action);
        add_action (bookmark_action);
        app.set_accels_for_action ("win.bookmark-action", {"<Ctrl>B"});

        headerbar.mode_changed.connect ((mode) => {
            set_mode (mode);
        });
    }

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

        headerbar.set_mode (ENotes.Mode.get_mode (settings.mode));

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
                view_edit_stack.set_page (page);
        }
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

    public void set_mode (ENotes.Mode mode) {
        if (mode == ENotes.Mode.VIEW) {
            view_edit_stack.show_view ();
            sidebar.visible = (true);
            viewer.load_string (editor.get_text ());
            editor.save_file ();
            pages_list.grab_focus ();
        } else {
            view_edit_stack.show_edit ();
            sidebar.visible = (false);
            editor.give_focus ();
            pane2.set_position (0);
        }
    }

    public void toggle_edit () {
        ENotes.Mode mode = headerbar.get_mode ();

        if (mode == ENotes.Mode.EDIT) {
            mode = ENotes.Mode.VIEW;
        } else {
            mode = ENotes.Mode.EDIT;
        }

        headerbar.set_mode (mode);
    }

    public void show_app () {
        show ();
        present ();

        set_focus (editor);
    }
}
