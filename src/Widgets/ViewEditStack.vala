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

public enum ENotes.Mode {
    VIEW = 0,
    EDIT = 1;

    public static ENotes.Mode get_mode (int value) {
        return (value == 1) ? EDIT : VIEW;
    }

    public static int get_value (ENotes.Mode value) {
        return (value == VIEW) ? 0 : 1;
    }
}

public class ENotes.ViewEditStack : Gtk.Grid {
    private static ViewEditStack? instance = null;
    private ENotes.Mode? current_mode = null;

    public signal void page_set (ENotes.Page page);

    public ENotes.Viewer viewer { get; private set; }
    public ENotes.Editor editor { get; private set; }
    private Gtk.Stack stack;

    public static ViewEditStack get_instance () {
        if (instance == null) {
            instance = new ViewEditStack ();
        }

        return instance;
    }

    private ViewEditStack () {
        stack = new Gtk.Stack ();

        editor = new ENotes.Editor ();
        viewer = new ENotes.Viewer ();

        stack.add_named (viewer, "viewer");
        stack.add_named (editor, "editor");

        stack.set_transition_type (Gtk.StackTransitionType.SLIDE_LEFT_RIGHT);

        this.add (stack);
        this.show_all ();

        show_view ();

        app.state.notify["mode"].connect (() => {
            if (app.state.mode == ENotes.Mode.EDIT) {
                show_edit ();
            } else {
                show_view ();
            }
        });
    }

    public void set_page (ENotes.Page page, bool dummy_page = true) {
        if (dummy_page) {
            if (PagesList.get_instance ().select_page (page)) {
                return;
            }
        }

        editor.save_file ();
        var current_page = PageTable.get_instance ().get_page (page.id);

        app.state.opened_page_notebook = ENotes.NotebookTable.get_instance().load_notebook_data (current_page.notebook_id);

        editor.current_page = current_page;
        viewer.load_page (current_page);

        page_set (current_page);

        if (page.data == "") {
            show_edit ();
        }

        editor.set_sensitive (!Trash.get_instance ().is_page_trashed (page));
        app.state.opened_page = current_page;
        app.state.update_page_title ();
    }

    private void show_edit () {
        if (current_mode == ENotes.Mode.EDIT) return;
        current_mode = ENotes.Mode.EDIT;

        stack.set_visible_child_name ("editor");

        if (!settings.keep_sidebar_visible) {
            Sidebar.get_instance().visible = false;
        }

        editor.give_focus ();
    }

    private void show_view () {
        if (current_mode == ENotes.Mode.VIEW) return;

        stack.set_visible_child_name ("viewer");

        Sidebar.get_instance().visible = true;
        PagesList.get_instance ().grab_focus ();

        current_mode = ENotes.Mode.VIEW;

        if (app.state.opened_page != null) {
            editor.save_file ();
            viewer.load_page (app.state.opened_page, true);
        }
    }
}
