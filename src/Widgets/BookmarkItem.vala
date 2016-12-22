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
    public ENotes.Notebook parent_notebook { public get; private set; }

    private ENotes.Bookmark bookmark;

    private Gtk.Menu menu;
    private Gtk.MenuItem remove_item;

    public BookmarkItem (string bookmark_file) {
        this.bookmark = new Bookmark.from_link (ENotes.NOTES_DIR + bookmark_file);

/*        if (bookmark.page.new_page) {
            this.bookmark.unbookmark ();
            this.visible = false;
            return;
        }*/

        this.name = bookmark.page.name;
//        this.parent_notebook = new ENotes.Notebook (bookmark.page.path);

        set_color (parent_notebook);

        setup_menu ();
        connect_signals ();
    }

    public ENotes.Page get_page () {
        return bookmark.page;
    }

    private void connect_signals () {
        bookmark.destroy.connect (() => {
            this.visible = false;
        });
    }

    private void setup_menu () {
        menu = new Gtk.Menu ();
        remove_item = new Gtk.MenuItem.with_label (_("Remove"));
        remove_item.activate.connect (() => {
            this.bookmark.unbookmark ();
            ENotes.BookmarkButton.get_instance ().setup ();
        });

        menu.add (remove_item);
        menu.show_all ();
    }

    public override Gtk.Menu? get_context_menu () {
        return menu;
    }
}
