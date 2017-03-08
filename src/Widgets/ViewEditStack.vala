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

public class ENotes.ViewEditStack : Gtk.Overlay {
    private static ViewEditStack? instance = null;
    public static ENotes.Mode? current_mode = null;

    public signal void page_set (ENotes.Page page);

    private ENotes.BookmarkButton bookmark_button;
    private ENotes.Viewer viewer;
    private ENotes.Editor editor;
    private Gtk.Stack stack;

    public ENotes.Page? current_page {get; private set; default = null;}

    public static ViewEditStack get_instance () {
        if (instance == null) {
            instance = new ViewEditStack ();
        }

        return instance;
    }

    private ViewEditStack () {
        stack = new Gtk.Stack ();

        viewer = ENotes.Viewer.get_instance ();
        editor = ENotes.Editor.get_instance ();
        bookmark_button = BookmarkButton.get_instance ();
        stack.add_named (viewer, "viewer");
        stack.add_named (editor, "editor");

        stack.set_transition_type (Gtk.StackTransitionType.SLIDE_LEFT_RIGHT);

        this.add (stack);
        this.show_all ();

        show_view ();
    }

    public void set_page (ENotes.Page page, bool dummy_page = true) {
        if (dummy_page) {
            if (PagesList.get_instance ().select_page (page)) {
                return;
            }
        }

        current_page = PageTable.get_instance ().get_page (page.id);
        editor.current_page = current_page;
        viewer.load_page (current_page);

        bookmark_button.set_page (current_page);
        page_set (current_page);

        if (page.name == _("New Page") && page.data == "") {
            show_edit ();
        }

        editor.set_sensitive (!Trash.get_instance ().is_page_trashed (page));
    }

    public ENotes.Page? get_page () {
        return current_page;
    }

    public void show_edit () {
        if (current_mode == ENotes.Mode.EDIT) return;
        current_mode = ENotes.Mode.EDIT;
        Headerbar.get_instance ().set_mode (ENotes.Mode.EDIT);
        stack.set_visible_child_name ("editor");
        if ( ! settings.keep_sidebar_visible)
        {
            Sidebar.get_instance().visible = false;
        }
        editor.give_focus ();
    }

    public void show_view () {
        if (current_mode == ENotes.Mode.VIEW || current_page == null) return;

        editor.save_file ();
        current_mode = ENotes.Mode.VIEW;
        viewer.load_page (current_page, true);

        Headerbar.get_instance ().set_mode (ENotes.Mode.VIEW);

        stack.set_visible_child_name ("viewer");
        Sidebar.get_instance().visible = true;

        PagesList.get_instance ().grab_focus ();
    }
}
