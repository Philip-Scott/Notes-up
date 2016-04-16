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

public class ENotes.ViewEditStack : Gtk.Overlay {
    public signal void page_set (ENotes.Page page);

    private ENotes.Page current_page;
    private Gtk.Stack stack;

    public ViewEditStack () {
        stack = new Gtk.Stack ();

        viewer = new ENotes.Viewer ();
        editor = new ENotes.Editor ();
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
        //bookmark_button.set_toolbar_mode (true);
    }
    public void show_view () {
        stack.set_visible_child_name ("viewer");
        //bookmark_button.set_toolbar_mode (false);
    }

}
