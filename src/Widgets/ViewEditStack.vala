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
    NONE = -1,
    VIEW = 0,
    EDIT = 1,
    BOTH = 2;


    public static ENotes.Mode get_mode (int value) {
        switch (value) {
            case 0: return VIEW;
            case 1: return EDIT;
            case 2: return BOTH;
            default: return 0;
        }
    }

    public static int get_value (ENotes.Mode value) {
        switch (value) {
            case VIEW: return 0;
            case EDIT: return 1;
            case BOTH: return 2;
            default: return 0;
        }
    }
}

public class ENotes.ViewEditStack : Gtk.Grid {
    private static ViewEditStack? instance = null;
    private ENotes.Mode? current_mode = null;

    public ENotes.Viewer viewer { get; private set; }
    public ENotes.Editor editor { get; private set; }
    public Gtk.Paned view_edit_pane;

    private Gtk.Stack stack;

    public static ViewEditStack get_instance () {
        if (instance == null) {
            instance = new ViewEditStack ();
        }

        return instance;
    }

    private ViewEditStack () {
        stack = new Gtk.Stack ();
        view_edit_pane = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
        view_edit_pane.position = view_edit_pane.max_position / 2;

        editor = new ENotes.Editor ();
        viewer = new ENotes.Viewer ();

        stack.add_named (viewer, "viewer");
        stack.add_named (editor, "editor");
        stack.add_named (view_edit_pane, "both");

        stack.set_transition_type (Gtk.StackTransitionType.SLIDE_LEFT_RIGHT);

        this.add (stack);
        this.show_all ();

        show_view ();

        app.state.notify["mode"].connect (() => {
            if (app.state.mode == ENotes.Mode.EDIT) {
                unset_both ();
                show_edit ();
            } else if (app.state.mode == ENotes.Mode.VIEW) {
                unset_both ();
                show_view ();
            } else {
                show_both ();
            }
        });

        app.state.notify["opened-page"].connect (() => {
            viewer.load_page (app.state.opened_page);

            if (app.state.mode == ENotes.Mode.VIEW && app.state.opened_page.data == "") {
                app.state.mode = ENotes.Mode.EDIT;
            }
        });
    }

    private void unset_both () {
        if (current_mode != ENotes.Mode.BOTH) return;
        view_edit_pane.remove (viewer);
        view_edit_pane.remove (editor);

        stack.add_named (viewer, "viewer");
        stack.add_named (editor, "editor");

        show_all ();
    }

    private void show_both () {
        if (current_mode == ENotes.Mode.BOTH) return;
        stack.remove (viewer);
        stack.remove (editor);

        view_edit_pane.pack1 (viewer, true, false);
        view_edit_pane.pack2 (editor, false, false);

        show_all ();

        stack.set_visible_child_name ("both");

        current_mode = ENotes.Mode.BOTH;
    }

    private void show_edit () {
        if (current_mode == ENotes.Mode.EDIT) return;
        current_mode = ENotes.Mode.EDIT;

        stack.set_visible_child_name ("editor");

        editor.give_focus ();
    }

    private void show_view () {
        if (current_mode == ENotes.Mode.VIEW) return;

        stack.set_visible_child_name ("viewer");

        PagesList.get_instance ().grab_focus ();

        current_mode = ENotes.Mode.VIEW;

        if (app.state.opened_page != null) {
            editor.save_file ();
            viewer.load_page (app.state.opened_page, true);
        }
    }
}
