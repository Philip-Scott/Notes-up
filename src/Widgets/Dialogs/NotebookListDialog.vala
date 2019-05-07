/*
* Copyright (c) 2017 Felipe Escoto (https://github.com/Philip-Scott/Notes-up)
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

public class ENotes.NotebookListDialog : Gtk.Dialog {

    public NotebookListDialog (ENotes.Notebook notebook) {
        title = _("Move Notebook");

        var notebook_list = new ENotes.Sidebar.notebook_list (notebook);
        notebook_list.margin = 12;
        get_content_area ().add (notebook_list);

        show_all ();
        show ();

        add_button (_("Cancel"), 1);

        var move = (Gtk.Button) this.add_button (_("Move"), 2);
        move.get_style_context ().add_class ("suggested-action");

        response.connect ((ID) => {
            switch (ID) {
                case 1:
                    break;
                case 2:
                    var item = notebook_list.selected as NotebookItem;
                    Notebook? parent_notebook = null;
                    if (item != null) {
                        parent_notebook = item.notebook;
                    }

                    NotebookTable.get_instance ().move_notebook (notebook, parent_notebook);
                    app.state.opened_notebook_updated ();
                    break;
            }

            this.close ();
        });
    }

    construct {
        set_size_request (450, 600);
        set_transient_for (window);
        modal = true;
    }

    public NotebookListDialog.to_move_page (ENotes.Page page_to_move) {
        title = _("Move Page");

        var notebook_list = new ENotes.Sidebar.notebook_list (null);

        notebook_list.margin = 12;
        get_content_area ().add (notebook_list);

        show_all ();
        show ();

        add_button (_("Cancel"), 1);

        var move = (Gtk.Button) this.add_button (_("Move"), 2);
        move.get_style_context ().add_class ("suggested-action");

        response.connect ((ID) => {
            switch (ID) {
                case 1:
                    break;
                case 2:
                    var item = notebook_list.selected as NotebookItem;

                    int64 notebook_id = 0;
                    if (item != null) {
                        notebook_id = item.notebook.id;
                    }

                    PageTable.get_instance ().move_to_notebook (page_to_move, notebook_id);
                    app.state.open_page (page_to_move.id);
                    app.state.notebook_contents_changed ();
                    break;
            }

            this.close ();
        });
    }
}
