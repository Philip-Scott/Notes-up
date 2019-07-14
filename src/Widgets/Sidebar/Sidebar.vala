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

public class ENotes.Sidebar : Granite.Widgets.SourceListPatch {
    private bool selecting_sidebar_item = false;

    private static Sidebar? instance = null;

    private Granite.Widgets.SourceListPatch.ExpandableItem bookmarks = new Granite.Widgets.SourceListPatch.ExpandableItem (_("Bookmarks"));
    private Granite.Widgets.SourceListPatch.ExpandableItem trash = new Granite.Widgets.SourceListPatch.ExpandableItem (_("Trash"));
    private Granite.Widgets.SourceListPatch.ExpandableItem tags = new Granite.Widgets.SourceListPatch.ExpandableItem (_("Tags"));
    private Granite.Widgets.SourceListPatch.Item? previous_selection = null;
    private Granite.Widgets.SourceListPatch.Item all_notes;

    private NotebookList notebooks = new NotebookList (_("Sections"));

    private Gee.HashMap<int, NotebookItem> added_notebooks;
    private Gee.HashMap<int, TagItem> added_tags;

    public static Sidebar get_instance () {
        if (instance == null) {
            instance = new Sidebar ();
        }

        return instance;
    }

    public Sidebar () {
        selecting_sidebar_item = true;

        notebooks.icon = new GLib.ThemedIcon ("notebook-symbolic");
        trash.icon = new GLib.ThemedIcon ("edit-delete-symbolic");
        tags.icon = new GLib.ThemedIcon ("tag-symbolic");
        bookmarks.icon = new GLib.ThemedIcon ("user-bookmarks-symbolic");

        build_new_ui (_("All Notes"));

        load_notebooks ();
        load_bookmarks ();
        load_tags ();

        connect_signals ();
        notebooks.collapse_all (true, true);
        root.expand_all (false, false);

        selecting_sidebar_item = false;

        try {
            var provider = new Gtk.CssProvider ();
            get_child ().get_style_context ().add_provider (provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
            provider.load_from_data (STYLE, STYLE.length);
        } catch (Error e) {
            warning ("Style error: %s", e.message);
        }

        app.state.post_database_change.connect (() => {
            selecting_sidebar_item = true;
            load_notebooks ();
            load_bookmarks ();
            load_tags ();
            connect_signals ();
            first_start ();

            trash.clear ();

            selecting_sidebar_item = false;
        });

        item_selected.connect ((item) => {
            if (selecting_sidebar_item) return;

            if (item != null && item is ENotes.BookmarkItem) {
                // If viewing page == the bookmark, select the notebook. if not just open the page
                if (app.state.opened_page.equals (((ENotes.BookmarkItem) item).get_page ())) {
                    app.state.open_notebook (((ENotes.BookmarkItem) item).parent_notebook);
                    app.state.open_page (((ENotes.BookmarkItem) item).get_page ().id);
                } else {
                    app.state.open_page (((ENotes.BookmarkItem) item).get_page ().id);
                    this.selected = previous_selection;
                }
            } else if (item is ENotes.NotebookItem) {
                previous_selection = item;
                ENotes.ViewEditStack.get_instance ().editor.save_file ();
                app.state.opened_notebook = ((ENotes.NotebookItem) item).notebook;
            } else if (item is ENotes.TagItem) {
                var tag_item = item as ENotes.TagItem;
                app.state.opened_notebook = null;
                app.state.show_pages_in_tag (tag_item.tag);
            } else if (item == all_notes) {
                app.state.opened_notebook = null;
                app.state.show_all_pages ();
            }
        });

        app.state.notify["opened-notebook"].connect (() => {
            var notebook = app.state.opened_notebook;

            if (notebook != null) {
                select_notebook (notebook.id);
            }
        });

        app.state.opened_notebook_updated.connect (() => {
            load_notebooks ();
        });

        app.state.tags_changed.connect (() => {
            load_tags ();
        });
    }

    public Sidebar.notebook_list (ENotes.Notebook? to_ignore) {
        get_child ().get_style_context ().remove_class ("source-list");
        get_child ().get_style_context ().remove_class ("view");

        build_new_ui (_("Not in a Notebook"));
        all_notes.use_pango_style = false;

        notebooks.expand_all (true, false);
        load_notebooks (false, to_ignore);
    }

    private void build_new_ui (string all_notes_title) {
        all_notes = new Granite.Widgets.SourceListPatch.Item (all_notes_title);

        all_notes.icon = new GLib.ThemedIcon ("text-x-generic-symbolic");
        all_notes.selectable = true;
        root.add (all_notes);

        root.add (notebooks);
        root.add (bookmarks);
        root.add (tags);
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
                if (add_menus) {
                    this.notebooks.add (item);
                } else {
                    root.add (item);
                }
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

    public void load_tags () {
        selecting_sidebar_item = true;

        var last_tag_selected = selected as TagItem;

        added_tags = new Gee.HashMap<int, TagItem>();
        tags.clear ();

        var tags_list = TagsTable.get_instance ().get_tags ();

        foreach (var tag in tags_list) {
            var tag_item = new TagItem (tag);
            tags.add (tag_item);
            added_tags.set ((int) tag.id, tag_item);
        }

        tags.expand_all ();

        selecting_sidebar_item = false;

        if (last_tag_selected != null) {
            select_tag (last_tag_selected.tag.id);
        }
    }

    private void select_tag (int64 _tag) {
        int tag = (int) _tag;

        if (added_tags.has_key (tag)) {
            var to_select = added_tags.get ((int) tag);
            selected = to_select;
        }
    }

    private void select_notebook (int64 notebook_id) {
        selecting_sidebar_item = true;

        if (added_notebooks.has_key ((int) notebook_id)) {
            var last_selected = selected as ENotes.NotebookItem;

            if (last_selected != null && last_selected.notebook.id != notebook_id) {
                var to_select = added_notebooks.get ((int) notebook_id) as ENotes.NotebookItem;
                selected = to_select;
            } else if (last_selected == null || selected == null) {
                var to_select = added_notebooks.get ((int) notebook_id) as ENotes.NotebookItem;
                selected = to_select;
            }
        }

        selecting_sidebar_item = false;
    }

    public void first_start () {
        if (notebooks.children.is_empty) {
            first_notebook ();
        }
    }

    private void first_notebook () {
        var notebook_id = NotebookTable.get_instance ().new_notebook (0, _("My Notes"), {1, 0, 0}, "", "");

        load_notebooks ();
        select_notebook (notebook_id);
    }

    private void connect_signals () {
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
            app.state.open_page (page.id);
        });

        Trash.get_instance ().notebook_added.connect ((notebook) => {
            var trash_item = new TrashItem.notebook (notebook);
            trash.add (trash_item);
        });

        Trash.get_instance ().notebook_removed.connect ((notebook) => {
            select_notebook (notebook.id);
        });
    }

    private const string STYLE = ".source-list {-gtk-icon-style: symbolic; }";
}
