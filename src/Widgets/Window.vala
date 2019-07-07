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
    private ENotes.PageInfoEditor page_info;
    private ENotes.ViewEditStack view_edit_stack;
    private ENotes.Viewer viewer;

    private FourPaneWindow panes;

    public Window (ENotes.Application app) {
        Object (application: app);

        var change_mode = new SimpleAction ("change-mode", null);
        var save_action = new SimpleAction ("save", null);
        var close_action = new SimpleAction ("close-action", null);
        var new_action = new SimpleAction ("new-action", null);
        var find_action = new SimpleAction ("find-action", null);
        var bookmark_action = new SimpleAction ("bookmark-action", null);
        var bold_action = new SimpleAction ("bold-action", null);
        var italics_action = new SimpleAction ("italics-action", null);
        var strike_action = new SimpleAction ("strike-action", null);
        var page_info_action = new SimpleAction ("page-info-action", null);

        add_action (change_mode);
        add_action (save_action);
        add_action (close_action);
        add_action (new_action);
        add_action (find_action);
        add_action (bookmark_action);
        add_action (bold_action);
        add_action (italics_action);
        add_action (strike_action);
        add_action (page_info_action);

        app.set_accels_for_action ("win.change-mode", {ENotes.Key.CHANGE_MODE.to_key() });
        app.set_accels_for_action ("win.save", {ENotes.Key.SAVE.to_key()});
        app.set_accels_for_action ("win.close-action", {ENotes.Key.QUIT.to_key()});
        app.set_accels_for_action ("win.new-action", {ENotes.Key.NEW_PAGE.to_key()});
        app.set_accels_for_action ("win.find-action", {ENotes.Key.FIND.to_key()});
        app.set_accels_for_action ("win.bookmark-action", {ENotes.Key.BOOKMARK.to_key()});
        app.set_accels_for_action ("win.bold-action", {ENotes.Key.BOLD.to_key()});
        app.set_accels_for_action ("win.italics-action", {ENotes.Key.ITALICS.to_key()});
        app.set_accels_for_action ("win.strike-action", {ENotes.Key.STRIKE.to_key()});
        app.set_accels_for_action ("win.page-info-action", {ENotes.Key.PAGE_INFO.to_key()});

        build_ui ();

        change_mode.activate.connect (app.state.toggle_app_mode);
        save_action.activate.connect (save);
        close_action.activate.connect (request_close);
        new_action.activate.connect (new_page);
        find_action.activate.connect (headerbar.show_search);
        bookmark_action.activate.connect (headerbar.bookmark_button.main_action);
        bold_action.activate.connect (bold_act);
        italics_action.activate.connect (italics_act);
        strike_action.activate.connect (strike_act);
        page_info_action.activate.connect (toggle_page_info);

        Sidebar.get_instance ().first_start ();

        var provider = new Gtk.CssProvider ();
        provider.load_from_resource ("/com/github/philip-scott/notes-up/Application.css");
        Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        app.state.notify["style-scheme"].connect (() => {
            get_style_context ().remove_class ("solarized-light");
            get_style_context ().remove_class ("solarized-dark");

            if (app.state.style_scheme != "high-contrast") {
                get_style_context ().add_class (app.state.style_scheme);
            }
        });

        app.state.pre_database_change.connect (() => {
            close_database_file ();
        });

        app.state.post_database_change.connect (() => {
            open_database ();
        });

        app.state.notify["panes-visible"].connect (() => {
            panes.show_n_panes (app.state.panes_visible);
        });

        load_settings ();
    }

    private void build_ui () {
        page_info = new ENotes.PageInfoEditor ();

        headerbar = new ENotes.Headerbar (page_info);

        set_titlebar (headerbar);

        set_events (Gdk.EventMask.BUTTON_PRESS_MASK);

        panes = new FourPaneWindow ();

        sidebar = ENotes.Sidebar.get_instance ();
        pages_list = ENotes.PagesList.get_instance ();

        view_edit_stack = ENotes.ViewEditStack.get_instance ();
        editor = ENotes.ViewEditStack.get_instance ().editor;
        viewer = ENotes.ViewEditStack.get_instance ().viewer;

        var main_area_grid = new Gtk.Grid ();
        main_area_grid.orientation = Gtk.Orientation.VERTICAL;

        main_area_grid.add (page_info);
        main_area_grid.add (view_edit_stack);

        var notebook_picker = new NotebookPicker ();

        panes.pack1 (notebook_picker);
        panes.pack2 (sidebar);
        panes.pack3 (pages_list);
        panes.pack4 (main_area_grid);

        this.move (settings.pos_x, settings.pos_y);
        this.add (panes);
        this.show_all ();
    }

    private void bold_act () {
        if (editor_open ()) ENotes.ViewEditStack.get_instance ().editor.bold_button.clicked ();
    }

    private void italics_act () {
        if (editor_open ()) ENotes.ViewEditStack.get_instance ().editor.italics_button.clicked ();
    }

    private void strike_act () {
        if (editor_open ()) ENotes.ViewEditStack.get_instance ().editor.strike_button.clicked ();
    }

    private bool editor_open () {
        return app.state.mode != ENotes.Mode.VIEW && app.state.opened_page != null;
    }

    protected override bool delete_event (Gdk.EventAny event) {
        int width;
        int height;
        int x;
        int y;

        close_database_file ();

        get_size (out width, out height);
        get_position (out x, out y);

        settings.pos_x = x;
        settings.pos_y = y;
        settings.notebook_panel_size = panes.position_2_3;
        settings.panel_size = panes.position_3_4;
        settings.window_width = width;
        settings.window_height = height;
        settings.mode = app.state.mode;
        settings.style_scheme = app.state.style_scheme;
        settings.show_page_info = app.state.show_page_info;
        settings.editor_font = app.state.editor_font;
        settings.editor_scheme = app.state.editor_scheme;
        settings.line_numbers = app.state.editor_show_line_numbers;
        settings.auto_indent = app.state.editor_auto_indent;
        settings.panes_visible = app.state.panes_visible;

        return false;
    }

    private void close_database_file () {
        editor.save_file ();

        var file_data = ENotes.FileDataTable.instance;
        var opened_notebook = app.state.opened_notebook;
        if (opened_notebook != null) {
            file_data.set_value_silent (FileDataType.LAST_NOTEBOOK, opened_notebook.id.to_string ());
        } else {
            file_data.set_value_silent (FileDataType.LAST_NOTEBOOK, "0");
        }

        var opened_page = app.state.opened_page;
        if (opened_page != null) {
            file_data.set_value_silent (FileDataType.LAST_PAGE, opened_page.id.to_string ());
        } else {
            file_data.set_value_silent (FileDataType.LAST_PAGE, "0");
        }

        Trash.get_instance ().clear_files ();
    }

    private void load_settings () {
        resize (settings.window_width, settings.window_height);
        panes.position_2_3 = settings.notebook_panel_size;
        panes.position_3_4 = settings.panel_size;

        app.state.mode = ENotes.Mode.get_mode (settings.mode);

        open_database ();

        app.state.set_style (settings.style_scheme);
        app.state.editor_scheme = settings.editor_scheme;
        app.state.show_page_info = settings.show_page_info;
        app.state.editor_font = settings.editor_font;
        app.state.editor_show_line_numbers = settings.line_numbers;
        app.state.editor_auto_indent = settings.auto_indent;
        app.state.panes_visible = settings.panes_visible;
    }

    private void open_database () {
        if (settings.last_page != 0) {
            // Legacy Boot
            app.state.open_notebook (settings.last_notebook);
            app.state.open_page (settings.last_page);

            settings.last_notebook = 0;
            settings.last_page = 0;
        } else {
            var file_data = ENotes.FileDataTable.instance;
            app.state.open_notebook (file_data.get_int64 (FileDataType.LAST_NOTEBOOK));
            app.state.open_page (file_data.get_int64 (FileDataType.LAST_PAGE));
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
        app.state.mode = mode;
    }

    public void show_app () {
        show ();
        present ();
    }

    public void toggle_page_info () {
        app.state.show_page_info = !app.state.show_page_info;
    }

    private class FourPaneWindow : Gtk.Bin {
        public int position_1_2 {
            get {
                return paned_1_2.position;
            } set {
                paned_1_2.position = value;
            }
        }

        public int position_2_3 {
            get {
                return paned_2_3.position;
            } set {
                paned_2_3.position = value;
            }
        }

        public int position_3_4 {
            get {
                return paned_3_4.position;
            } set {
                paned_3_4.position = value;
            }
        }

        public bool show_1 {
            get {
                return widget_1.visible;
            } set {
                widget_1.visible = value;
                widget_1.no_show_all = !value;
            }
        }

        public bool show_2 {
            get {
                return widget_2.visible;
            } set {
                widget_2.visible = value;
                widget_2.no_show_all = !value;
            }
        }

        public bool show_3 {
            get {
                return widget_3.visible;
            } set {
                widget_3.visible = value;
                widget_3.no_show_all = !value;
            }
        }

        public bool show_4 {
            get {
                return widget_4.visible;
            } set {
                widget_4.visible = value;
                widget_4.no_show_all = !value;
            }
        }

        private unowned Gtk.Widget widget_1;
        private unowned Gtk.Widget widget_2;
        private unowned Gtk.Widget widget_3;
        private unowned Gtk.Widget widget_4;

        private Gtk.Paned paned_1_2;
        private Gtk.Paned paned_2_3;
        private Gtk.Paned paned_3_4;

        construct {
            paned_1_2 = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
            paned_2_3 = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
            paned_3_4 = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);

            paned_1_2.pack2 (paned_2_3, true, false);
            paned_2_3.pack2 (paned_3_4, true, false);

            add (paned_1_2);
        }

        public void show_n_panes (int amount) {
            show_1 = amount >= 3;
            show_2 = amount >= 2;
            show_3 = amount >= 1;
        }

        public void pack1 (Gtk.Widget widget) {
            widget_1 = widget;
            paned_1_2.pack1 (widget, false, false);
        }

        public void pack2 (Gtk.Widget widget) {
            widget_2 = widget;
            paned_2_3.pack1 (widget, false, false);
        }

        public void pack3 (Gtk.Widget widget) {
            widget_3 = widget;
            paned_3_4.pack1 (widget, false, false);
        }

        public void pack4 (Gtk.Widget widget) {
            widget_4 = widget;
            paned_3_4.pack2 (widget, true, false);
        }
    }
}
