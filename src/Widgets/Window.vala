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
    private ENotes.Editor editor;
    private ENotes.Headerbar headerbar;
    private ENotes.PagesList pages_list;
    private ENotes.Sidebar sidebar;
    private ENotes.ViewEditStack view_edit_stack;
    private ENotes.Viewer viewer;

    private Gtk.Paned pane1;
    private Gtk.Paned pane2;

    private SimpleAction change_mode;
    private SimpleAction save_action;
    private SimpleAction close_action;
    private SimpleAction new_action;
    private SimpleAction find_action;
    private SimpleAction bookmark_action;
    private SimpleAction bold_action;
    private SimpleAction italics_action;
    private SimpleAction strike_action;

    public Window (Gtk.Application app) {
        Object (application: app);
        DatabaseTable.init (ENotes.NOTES_DB);

        change_mode = new SimpleAction ("change-mode", null);
        save_action = new SimpleAction ("save", null);
        close_action = new SimpleAction ("close-action", null);
        new_action = new SimpleAction ("new-action", null);
        find_action = new SimpleAction ("find-action", null);
        bookmark_action = new SimpleAction ("bookmark-action", null);
        bold_action = new SimpleAction ("bold-action", null);
        italics_action = new SimpleAction ("italics-action", null);
        strike_action = new SimpleAction ("strike-action", null);

        add_action (change_mode);
        add_action (save_action);
        add_action (close_action);
        add_action (new_action);
        add_action (find_action);
        add_action (bookmark_action);
        add_action (bold_action);
        add_action (italics_action);
        add_action (strike_action);

        app.set_accels_for_action ("win.change-mode", {ENotes.Key.CHANGE_MODE.to_key() });
        app.set_accels_for_action ("win.save", {ENotes.Key.SAVE.to_key()});
        app.set_accels_for_action ("win.close-action", {ENotes.Key.QUIT.to_key()});
        app.set_accels_for_action ("win.new-action", {ENotes.Key.NEW_PAGE.to_key()});
        app.set_accels_for_action ("win.find-action", {ENotes.Key.FIND.to_key()});
        app.set_accels_for_action ("win.bookmark-action", {ENotes.Key.BOOKMARK.to_key()});
        app.set_accels_for_action ("win.bold-action", {ENotes.Key.BOLD.to_key()});
        app.set_accels_for_action ("win.italics-action", {ENotes.Key.ITALICS.to_key()});
        app.set_accels_for_action ("win.strike-action", {ENotes.Key.STRIKE.to_key()});

        build_ui ();

        change_mode.activate.connect (toggle_edit);
        save_action.activate.connect (save);
        close_action.activate.connect (request_close);
        new_action.activate.connect (new_page);
        find_action.activate.connect (headerbar.show_search);
        bookmark_action.activate.connect (BookmarkButton.get_instance ().main_action);
        bold_action.activate.connect (bold_act);
        italics_action.activate.connect (italics_act);
        strike_action.activate.connect (strike_act);
        headerbar.mode_changed.connect ((mode) => {
            set_mode (mode);
        });

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

        this.move (settings.pos_x, settings.pos_y);
        this.add (pane1);
        this.show_all ();
    }

    private void bold_act () {
        if (editor_open ()) Editor.get_instance ().bold_button.clicked ();
    }

    private void italics_act () {
        if (editor_open ()) Editor.get_instance ().italics_button.clicked ();
    }

    private void strike_act () {
        if (editor_open ()) Editor.get_instance ().strike_button.clicked ();
    }

    private bool editor_open () {
        return ViewEditStack.current_mode == ENotes.Mode.EDIT && ViewEditStack.get_instance ().current_page != null;
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
        settings.notebook_panel_size = pane1.position;
        settings.panel_size = pane2.position;
        settings.window_width = width;
        settings.window_height = height;
        settings.mode = ENotes.ViewEditStack.current_mode;
        settings.last_notebook = (int) PagesList.get_instance ().current_notebook.id;
        settings.last_page = (int) ViewEditStack.get_instance ().current_page.id;

        Trash.get_instance ().clear_files ();

        return false;
    }

    private void load_settings () {
        resize (settings.window_width, settings.window_height);
        pane1.position = settings.notebook_panel_size;
        pane2.position = settings.panel_size;

        if (settings.last_notebook != 0) {
            var notebook = NotebookTable.get_instance ().load_notebook_data (settings.last_notebook);
            if (notebook != null) {
                PagesList.get_instance ().load_pages (notebook);
                Sidebar.get_instance ().select_notebook (notebook.id);
            }
        }

        if (settings.last_page != 0) {
            var last_page = PageTable.get_instance ().get_page (settings.last_page);
            if (last_page != null) {
                ViewEditStack.get_instance ().set_page (last_page);
            }
        }

        if (ENotes.Mode.get_mode (settings.mode) == Mode.EDIT) {
            ENotes.ViewEditStack.get_instance ().show_edit ();
        } else {
            ENotes.ViewEditStack.get_instance ().show_view ();
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
        } else {
            view_edit_stack.show_edit ();
        }
    }

    public void toggle_edit () {
        ENotes.Mode mode = ENotes.ViewEditStack.current_mode;

        if (mode == ENotes.Mode.EDIT) {
            ENotes.ViewEditStack.get_instance ().show_view ();
        } else {
            ENotes.ViewEditStack.get_instance ().show_edit ();
        }
    }

    public void show_app () {
        show ();
        present ();
    }
}
