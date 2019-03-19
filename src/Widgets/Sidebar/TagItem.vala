/*
* Copyright (c) 2019 Felipe Escoto (https://github.com/Philip-Scott/Notes-up)
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

public class ENotes.TagItem : ENotes.SidebarItem {
    public ENotes.Tag tag { get; private set; }

    private Gtk.Menu menu;
    private Gtk.MenuItem remove_item;

    public TagItem (Tag tag) {
        this.tag = tag;
        this.name = tag.name;

        //  editable = true;

        setup_menu ();

        //  edited.connect ((new_name) => {
        //      BookmarkTable.get_instance ().rename (this.tag.page_id, new_name);
        //  });
    }


    private void setup_menu () {
        menu = new Gtk.Menu ();
        remove_item = new Gtk.MenuItem.with_label (_("Remove"));
        remove_item.activate.connect (() => {
            //  BookmarkTable.get_instance ().remove (this.tag.page_id);
            //  app.state.tag_changed ();
            visible = false;
        });

        menu.add (remove_item);
        menu.show_all ();
    }

    public override Gtk.Menu? get_context_menu () {
        return menu;
    }
}
