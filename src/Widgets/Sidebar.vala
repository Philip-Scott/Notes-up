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

public class ENotes.Sidebar : Granite.Widgets.SourceList {

    private Granite.Widgets.SourceList.ExpandableItem notebooks = new Granite.Widgets.SourceList.ExpandableItem (_("Notebooks"));
    private Granite.Widgets.SourceList.ExpandableItem bookmarks = new Granite.Widgets.SourceList.ExpandableItem (_("Bookmarks"));

    public Sidebar () {
        build_new_ui ();
        load_notebooks ();
        load_bookmarks ();
        connect_signals ();
        notebooks.collapse_all (true, true);
         root.expand_all (false, false);
    }

    private void build_new_ui () {
        root.add (notebooks);
        root.add (bookmarks);

        can_focus = false;
        this.width_request = 150;
    }

    public void load_notebooks () {
        this.notebooks.clear ();

        var notebook_list = FileManager.load_notebooks ();

           foreach (ENotes.Notebook nb in notebook_list) {
            var notebook = new NotebookItem (nb);
            this.notebooks.add (notebook);

            load_sub_notebooks (notebook);
        }
    }

    public void load_sub_notebooks (NotebookItem item) {
        if (item.notebook.sub_notebooks.length () > 0) {
                foreach (ENotes.Notebook nb in item.notebook.sub_notebooks) {
                var new_item = new NotebookItem (nb);
                item.add (new_item);

                load_sub_notebooks (new_item);
                item.collapse_all ();
            }
        }
    }

    public void load_bookmarks () {
        this.bookmarks.clear ();

        var bookmark_list = FileManager.load_bookmarks ();

        foreach (string bm in bookmark_list) {
            var bookmark = new BookmarkItem (bm);
            this.bookmarks.add (bookmark);
        }

        bookmarks.expand_all ();
    }

    public void select_notebook (string name) {
        select_sub_notebook (notebooks, name);
    }

    private bool select_sub_notebook (Granite.Widgets.SourceList.ExpandableItem parent, string name) {
        foreach (var child in parent.children) {
            if (child.name == name) {
                selected = child;
                return true;
            }

            if (child is NotebookItem && ((NotebookItem) child).n_children > 0) {
                bool found = select_sub_notebook ((NotebookItem) child, name);
                if (found) return true;
            }
        }

        return false;
    }

    public void first_start () {
        if (notebooks.children.is_empty) {
            first_notebook ();
        }
    }

    private void first_notebook () {
        var dir = FileManager.create_notebook ("Unamed Notebook", 1, 0, 0);
        var notebook = new ENotes.Notebook (ENotes.NOTES_DIR + dir);

        var notebook_item = new NotebookItem (notebook);
        this.notebooks.add (notebook_item);

        select_notebook (notebook.name);
    }

    private void connect_signals () {
        this.item_selected.connect ((item) => {
            if (item == null) return;

            if (item is BookmarkItem) {
                select_notebook (((ENotes.BookmarkItem) item).parent_notebook.name);
                pages_list.select_page (((ENotes.BookmarkItem) item).get_page ());
                return;
            } else {
                ((NotebookItem) item).expand_all (true, true);
            }

            editor.save_file ();
            pages_list.load_pages (((ENotes.NotebookItem) item).notebook);
        });
    }
}
