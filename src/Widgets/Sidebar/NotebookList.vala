/*
* Copyright (c) 2011-2018 Felipe Escoto (https://github.com/Philip-Scott/Notes-up)
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
* Authored by: Darshak Parikh <darshak@protonmail.com>
*/

public class ENotes.NotebookList : Granite.Widgets.SourceListPatch.ExpandableItem {
    private Gtk.Menu menu;
    private Gtk.MenuItem new_notebook_item;

    public NotebookList (string name) {
        Object (name: name);
    }

    construct {
        menu = new Gtk.Menu ();
        new_notebook_item = new Gtk.MenuItem.with_label (_("New Section"));

        menu.add (new_notebook_item);
        menu.show_all ();

        new_notebook_item.activate.connect (() => {
            var dialog = new NotebookDialog ();
            dialog.run ();
        });
    }

    public override Gtk.Menu? get_context_menu () {
        return menu;
    }
}
