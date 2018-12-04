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

public class ENotes.PagesList : Gtk.Box {
    private static PagesList? instance = null;

    public Gtk.ListBox listbox;
    private Gtk.Frame toolbar;

    private Gtk.Separator separator;
    private Gtk.Button minus_button;
    private Gtk.Button plus_button;
    private Gtk.Label notebook_name;
    private Gtk.Label page_total;

    public ENotes.Notebook current_notebook;

    private string search_for = "";
    private bool loading_pages = false;

    private Gee.HashMap<int, PageItem> added_pages;

    public static PagesList get_instance () {
        if (instance == null) {
            instance = new PagesList ();
        }

        return instance;
    }

    private PagesList () {
        added_pages = new Gee.HashMap<int, PageItem>();

        PageTable.get_instance ();

        build_ui ();
        connect_signals ();
    }

    private void build_ui () {
        orientation = Gtk.Orientation.VERTICAL;

        var scroll_box = new Gtk.ScrolledWindow (null, null);
        listbox = new Gtk.ListBox ();
        listbox.vexpand = true;
        listbox.set_selection_mode (Gtk.SelectionMode.MULTIPLE);
        listbox.activate_on_single_click = false;
        listbox.set_size_request (200,250);
        listbox.set_filter_func ((row) => {
            bool found;
            if (this.search_for == "") {
                found = true;
            } else {
                found = ((PageItem) row).page.data.down ().contains (this.search_for.down ());
            }

            return found;
        });

        listbox.set_sort_func ((row1, row2) => {
            int64 a = ((PageItem) row1).page.id;
            int64 b = ((PageItem) row2).page.id;

            if (a > b) return -1;
            if (b > a) return 1;

            return 0;
        });

        scroll_box.set_size_request (200,250);
        toolbar = build_toolbar ();

        scroll_box.add (listbox);
        this.add (scroll_box);
        this.add (toolbar);

        toolbar_mode (ENotes.ViewEditStack.current_mode);
    }

    private Gtk.Frame build_toolbar () {
        var frame = new Gtk.Frame (null);
        var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);

        plus_button = new Gtk.Button.from_icon_name ("document-new-symbolic", Gtk.IconSize.SMALL_TOOLBAR);

        plus_button.set_tooltip_markup (Granite.markup_accel_tooltip (app.get_accels_for_action ("win.new-action"), _("New Page")));
        plus_button.get_style_context ().add_class ("flat");
        plus_button.can_focus = false;

        minus_button = new Gtk.Button.from_icon_name ("edit-delete-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
        minus_button.set_tooltip_text (_("Delete Page"));
        minus_button.get_style_context ().add_class ("flat");
        minus_button.halign = Gtk.Align.END;
        minus_button.no_show_all = true;
        minus_button.can_focus = false;
        minus_button.visible = false;

        notebook_name = new Gtk.Label ("");
        page_total = new Gtk.Label ("");
        separator = new Gtk.Separator (Gtk.Orientation.VERTICAL);

        notebook_name.halign = Gtk.Align.START;
        page_total.halign = Gtk.Align.END;

        separator.visible = false;
        notebook_name.hexpand = true;
        separator.no_show_all = true;

        notebook_name.ellipsize = Pango.EllipsizeMode.END;
        notebook_name.get_style_context ().add_class ("h4");
        notebook_name.margin_start = 6;
        notebook_name.margin_end = 6;
        page_total.margin_end = 6;

        box.add (notebook_name);
        box.add (page_total);
        box.add (new Gtk.Separator (Gtk.Orientation.VERTICAL));
        box.add (minus_button);
        box.add (separator);
        box.add (plus_button);

        frame.set_sensitive (false);
        frame.get_style_context ().add_class ("toolbar");
        frame.get_style_context ().add_class ("inline-toolbar");

        frame.add (box);
        frame.show_all ();

        return frame;
    }

    public void clear_pages () {
        listbox.unselect_all ();
        added_pages = new Gee.HashMap<int, PageItem>();
        var childerns = listbox.get_children ();

        foreach (Gtk.Widget child in childerns) {
            if (child is Gtk.ListBoxRow) {
                listbox.remove (child);
            }
        }
    }

    public void refresh () {
        load_pages (current_notebook);
    }

    public bool select_page (ENotes.Page? page) {
        if (page == null) return false;
        var childerns = listbox.get_children ();

        foreach (Gtk.Widget child in childerns) {
            if (child is ENotes.PageItem) {
                var item = child as ENotes.PageItem;

                if (page.equals (item.page)) {
                    listbox.select_row (item);
                    return true;
                }
            }
        }

        return false;
    }

    public void load_pages (ENotes.Notebook? notebook) {
        if (notebook == null) return;
        loading_pages = true;
        clear_pages ();

        this.current_notebook = notebook;
        var pages = PageTable.get_instance ().get_pages (notebook.id);

        foreach (ENotes.Page page in pages) {
            new_page (page);
        }

        toolbar.set_sensitive (true);
        minus_button.set_sensitive (false);

        var page_label = dngettext ("notes-up", "%i Page", "%i Pages", added_pages.size);
        page_total.label = page_label.printf (added_pages.size);

        this.notebook_name.label = notebook.name.split ("§")[0] + ":";
        listbox.show_all ();

        select_page (ENotes.ViewEditStack.get_instance ().current_page);
        loading_pages = false;
    }

    private ENotes.PageItem new_page (ENotes.Page page) {
        var page_box = new ENotes.PageItem (page);
        listbox.add (page_box);

        added_pages.set ((int)page.id, page_box);

        return page_box;
    }

    public void new_blank_page () {
        ENotes.Editor.get_instance ().save_file ();
        var page = PageTable.get_instance ().new_page (current_notebook.id);
        var page_item = new ENotes.PageItem (page);

        added_pages.set ((int) page.id, page_item);

        listbox.prepend (page_item);
        listbox.show_all ();
        listbox.unselect_all ();
        listbox.select_row (page_item);
    }

    public new void grab_focus () {
        listbox.grab_focus ();
    }

    private void toolbar_mode (Mode? mode) {
        separator.visible = (mode == Mode.EDIT);
        minus_button.visible = (mode == Mode.EDIT);
        page_total.visible = !(mode == Mode.EDIT);
    }

    private void connect_signals () {
        Headerbar.get_instance().mode_changed.connect ((mode) => {
            toolbar_mode (mode);
        });

        Headerbar.get_instance().search_changed.connect (() => {
            this.search_for = Headerbar.get_instance().search_entry.get_text ();
            listbox.invalidate_filter ();
        });

        Headerbar.get_instance().search_selected.connect (() => {
            listbox.select_row (listbox.get_row_at_y (0));
            listbox.get_row_at_y (0).grab_focus ();
        });

        plus_button.clicked.connect (() => {
            new_blank_page ();
        });

        minus_button.clicked.connect (() => {
            ENotes.Editor.get_instance ().set_sensitive (false);
            Headerbar.get_instance().set_title (null, null);

            var rows = listbox.get_selected_rows ();

            foreach (var row in rows) {
                Trash.get_instance ().trash_page (((ENotes.PageItem) row).page);
            }

            refresh ();
        });

        listbox.row_selected.connect ((row) => {
            if (row == null || loading_pages) return;
            minus_button.set_sensitive (true);
            ENotes.ViewEditStack.get_instance ().set_page (((ENotes.PageItem) row).page, false);
        });

        listbox.row_activated.connect ((row) => {
            window.toggle_edit ();

            if (ENotes.ViewEditStack.current_mode == Mode.EDIT) {
                ENotes.Editor.get_instance ().give_focus ();
            }
        });

        PageTable.get_instance ().page_saved.connect ((page) => {
            if (this.added_pages.has_key ((int) page.id)) {
                var page_item = added_pages.get ((int) page.id);
                page_item.page = page;
                page_item.load_data ();
            }
        });
    }

    // TODO: Replace this and above with P_ when https://bugzilla.gnome.org/show_bug.cgi?id=758000 is fixed.
    private void translations () {
        ngettext ("%i Page", "%i Pages", 0);
    }
}
