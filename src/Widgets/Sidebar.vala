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
    enum DropTargets {
        STRING,
        TEXT
    }

    private static Gtk.TargetEntry[] targets = get_target_entries ();

    private static Sidebar? instance = null;

    private Granite.Widgets.SourceList.ExpandableItem notebooks = new Granite.Widgets.SourceList.ExpandableItem (_("Notebooks"));
    private Granite.Widgets.SourceList.ExpandableItem bookmarks = new Granite.Widgets.SourceList.ExpandableItem (_("Bookmarks"));
    private Granite.Widgets.SourceList.ExpandableItem trash = new Granite.Widgets.SourceList.ExpandableItem (_("Trash"));
    private Granite.Widgets.SourceList.Item? previous_selection = null;

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

    private void build_new_ui () {
        root.add (notebooks);
        root.add (bookmarks);
        root.add (trash);

        can_focus = false;
        this.width_request = 150;
    }

    public void load_notebooks () {
        this.notebooks.clear ();

        var notebook_list = FileManager.load_notebooks ();

        foreach (ENotes.Notebook nb in notebook_list) {
            if (Trash.get_instance ().is_notebook_trashed (nb) == false) {
                var notebook = new NotebookItem (nb);
                this.notebooks.add (notebook);

                load_sub_notebooks (notebook);
            } else {
                stderr.printf ("something is trashed\n");
            }
        }
    }

    public void load_sub_notebooks (NotebookItem item) {
        if (item.notebook.sub_notebooks.length () > 0) {
            foreach (ENotes.Notebook nb in item.notebook.sub_notebooks) {
                if (Trash.get_instance ().is_notebook_trashed (nb) == false) {
                    var new_item = new NotebookItem (nb);
                    item.add (new_item);

                    load_sub_notebooks (new_item);
                    item.collapse_all ();
                }
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
        var dir = FileManager.create_notebook (_("Unamed Notebook"), 1, 0, 0);
        var notebook = new ENotes.Notebook (ENotes.NOTES_DIR + dir);

        var notebook_item = new NotebookItem (notebook);
        this.notebooks.add (notebook_item);

        select_notebook (notebook.name);
    }

    private static Gtk.TargetEntry[] get_target_entries () {
        if (targets == null) {
            Gtk.TargetEntry string_entry = { "STRING", 0, DropTargets.STRING };
            Gtk.TargetEntry text_entry = { "text/plain", 0, DropTargets.TEXT };

            targets = { };
            targets += string_entry;
            targets += text_entry;
         }

         return targets;
    }

    private void connect_signals () {
        enable_drag_source (get_target_entries ());
        enable_drag_dest (get_target_entries (), Gdk.DragAction.MOVE);

        this.item_selected.connect ((item) => {
            if (item != null && item is ENotes.BookmarkItem) {
                // If viewing page == the bookmark, select the notebook. if not just open the page
                if (ENotes.ViewEditStack.get_instance ().get_page ().equals (((ENotes.BookmarkItem) item).get_page ())) {
                    select_notebook (((ENotes.BookmarkItem) item).parent_notebook.name);
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
            load_notebooks ();
            select_notebook (notebook.name);
        });
    }
}
