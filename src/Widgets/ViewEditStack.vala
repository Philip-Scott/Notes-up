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

    public signal void page_set (ENotes.Page page);

    private ENotes.BookmarkButton bookmark_button;
    private ENotes.Viewer viewer;
    private ENotes.Editor editor;
    private Gtk.Stack stack;

    private ENotes.Page current_page;

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
        stack.add_named (editor, "editor");
        stack.add_named (viewer, "viewer");

        this.add (stack);
        this.show_all ();
    }

    public void set_page (ENotes.Page page) {
        current_page = page;
        editor.set_page (page);

        bookmark_button.set_page (page);

        page_set (page);
    }
    public ENotes.Page get_page () {
        return current_page;
    }

    public void show_edit () {
        stack.set_visible_child_name ("editor");
    }
    public void show_view () {
        stack.set_visible_child_name ("viewer");
    }
}
