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
    private static Sidebar? instance = null;

    private Granite.Widgets.SourceList.ExpandableItem bookmarks = new Granite.Widgets.SourceList.ExpandableItem (_("Bookmarks"));
    private Granite.Widgets.SourceList.ExpandableItem trash = new Granite.Widgets.SourceList.ExpandableItem (_("Trash"));
    private Granite.Widgets.SourceList.Item? previous_selection = null;
    private NotebookList notebooks = new NotebookList (_("Notebooks"));

    private Gee.HashMap<int, NotebookItem> added_notebooks;

    public static Sidebar get_instance () {
        if (instance == null) {
            instance = new Sidebar ();
        }

        return instance;
    }

    private Sidebar () {
        build_new_ui ();
        load_notebooks ();
        load_bookmarks ();
        connect_signals ();
        notebooks.collapse_all (true, true);
        root.expand_all (false, false);
    }
    
    public Sidebar.notebook_list (ENotes.Notebook to_ignore) {
        build_new_ui ();
        notebooks.expand_all (true, false);
        load_notebooks (false, to_ignore);
    }

    private void build_new_ui () {
        root.add (notebooks);
        root.add (bookmarks);
        root.add (trash);

        can_focus = false;
        this.width_request = 150;
    }

    public void load_notebooks (bool add_menus = true, ENotes.Notebook? to_ignore = null) {
        this.notebooks.clear ();

        var notebook_list = NotebookTable.get_instance ().get_notebooks ();
        added_notebooks = new Gee.HashMap<int, NotebookItem>();
        var to_add = new Gee.ArrayList<NotebookItem>();

        foreach (ENotes.Notebook notebook in notebook_list) {       
            var item = new NotebookItem (notebook, add_menus);
            added_notebooks.set ((int) notebook.id, item);
            
            if (to_ignore != null && to_ignore.id == notebook.id) continue;

            if (notebook.parent_id == 0) {
                this.notebooks.add (item);
            } else {
                to_add.add (item);
            }
        }

        foreach (var item in to_add) {
            if (added_notebooks.has_key ((int) item.notebook.parent_id)) {
                added_notebooks.get ((int) item.notebook.parent_id).add (item);
            }
        }
    }

    public void load_bookmarks () {
        this.bookmarks.clear ();

        var bookmark_list = BookmarkTable.get_instance ().get_bookmarks ();

        foreach (var bm in bookmark_list) {
            var bookmark = new BookmarkItem (bm);
            this.bookmarks.add (bookmark);
        }

        bookmarks.expand_all ();
    }

    public void select_notebook (int64 notebook_id) {
        if (added_notebooks.has_key ((int) notebook_id)) {
            selected = added_notebooks.get ((int) notebook_id);
        }
    }

    public void first_start () {
        if (notebooks.children.is_empty) {
            first_notebook ();
        }
    }

    private void first_notebook () {
        var notebook_id = NotebookTable.get_instance ().new_notebook (0, _("My First Notebook"), {1, 0, 0}, "", "");

        load_notebooks ();
        select_notebook (notebook_id);
    }

    private void connect_signals () {
        this.item_selected.connect ((item) => {
            if (item != null && item is ENotes.BookmarkItem) {
                // If viewing page == the bookmark, select the notebook. if not just open the page
                if (ENotes.ViewEditStack.get_instance ().current_page.equals (((ENotes.BookmarkItem) item).get_page ())) {
                    select_notebook (((ENotes.BookmarkItem) item).parent_notebook);
                    ENotes.PagesList.get_instance ().select_page (((ENotes.BookmarkItem) item).get_page ());
                } else {
                    ENotes.ViewEditStack.get_instance ().set_page (((ENotes.BookmarkItem) item).get_page ());
                    this.selected = previous_selection;
                }
            } else if (item is ENotes.NotebookItem) {
                previous_selection = item;
                ENotes.Editor.get_instance ().save_file ();
                ENotes.PagesList.get_instance ().load_pages (((ENotes.NotebookItem) item).notebook);
            }
        });

        NotebookTable.get_instance ().notebook_added.connect ((notebook) => {
            var item = new NotebookItem (notebook, true);

            var parent_id = (int) notebook.parent_id;
            if (parent_id == 0) {
                this.notebooks.add (item);
            } else {
                if (added_notebooks.has_key (parent_id)) {
                    added_notebooks.get (parent_id).add (item);
                }
            }

            added_notebooks.set ((int) notebook.id, item);
        });

        NotebookTable.get_instance ().notebook_changed.connect ((notebook) => {
            if (added_notebooks.has_key ((int) notebook.id)) {
                added_notebooks.get ((int) notebook.id).notebook = notebook;
            }
        });

        Trash.get_instance ().page_added.connect ((page) => {
            var trash_item = new TrashItem.page (page);
            trash.add (trash_item);
        });

        Trash.get_instance ().page_removed.connect ((page) => {
            ViewEditStack.get_instance ().set_page (page);
        });

        Trash.get_instance ().notebook_added.connect ((notebook) => {
            var trash_item = new TrashItem.notebook (notebook);
            trash.add (trash_item);
        });

        Trash.get_instance ().notebook_removed.connect ((notebook) => {
            select_notebook (notebook.id);
        });
    }
}
