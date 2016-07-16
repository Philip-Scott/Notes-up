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

public class ENotes.NotebookItem : ENotes.SidebarItem , Granite.Widgets.SourceListDragDest, Granite.Widgets.SourceListDragSource {

    public ENotes.Notebook notebook { public get; private set; }

    private Gtk.Menu menu;
    private Gtk.MenuItem remove_item;
    private Gtk.MenuItem edit_item;
    private Gtk.MenuItem new_item;

    public NotebookItem (ENotes.Notebook notebook) {
        this.notebook = notebook;
        set_color (notebook);

        this.name = notebook.name;

        setup_menu ();
        connect_signals ();
    }

    private void connect_signals () {

    }

    private void setup_menu () {
        menu = new Gtk.Menu ();
        edit_item = new Gtk.MenuItem.with_label (_("Edit Notebook"));
        new_item = new Gtk.MenuItem.with_label (_("New Section"));
        remove_item = new Gtk.MenuItem.with_label (_("Delete Notebook"));
        menu.add (edit_item);
        menu.add (remove_item);
        menu.add (new_item);
        menu.show_all ();

        edit_item.activate.connect (() => {
            new NotebookDialog (this.notebook);
        });

        new_item.activate.connect (() => {
            new NotebookDialog.new_subnotebook (this.notebook);
        });

        remove_item.activate.connect (() => {
            notebook.trash ();
        });

        notebook.destroy.connect (() => {
            this.visible = false;
        });
    }

    public override Gtk.Menu? get_context_menu () {
        return menu;
    }

    public bool data_drop_possible (Gdk.DragContext context, Gtk.SelectionData data) {
        return data.get_text () != notebook.path;
    }

    public Gdk.DragAction data_received (Gdk.DragContext context, Gtk.SelectionData data) {
        stderr.printf ("Got %s in %s", data.get_text (), notebook.path);
        return Gdk.DragAction.COPY;
    }

    public bool draggable () {
        return true;
    }

    public void prepare_selection_data (Gtk.SelectionData data) {
        data.set_text (notebook.path, -1);
    }
}

