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

public class ENotes.BookmarkItem : ENotes.SidebarItem {
    public int64 parent_notebook {
        get {
            return get_page ().notebook_id;
        }
    }

    private ENotes.Bookmark bookmark;

    private Gtk.Menu menu;
    private Gtk.MenuItem remove_item;

    public BookmarkItem (Bookmark bookmark) {
        this.bookmark = bookmark;
        this.name = bookmark.name;

        editable = true;

        set_color (bookmark.color);
        setup_menu ();

        edited.connect ((new_name) => {
            BookmarkTable.get_instance ().rename (this.bookmark.page_id, new_name);
        });
    }

    public ENotes.Page get_page () {
        return PageTable.get_instance ().get_page (bookmark.page_id);
    }

    private void setup_menu () {
        menu = new Gtk.Menu ();
        remove_item = new Gtk.MenuItem.with_label (_("Remove"));
        remove_item.activate.connect (() => {
            BookmarkTable.get_instance ().remove (this.bookmark.page_id);
            ENotes.BookmarkButton.get_instance ().setup ();
            this.visible = false;
        });

        menu.add (remove_item);
        menu.show_all ();
    }

    public override Gtk.Menu? get_context_menu () {
        return menu;
    }
}
