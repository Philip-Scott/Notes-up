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

    public static PagesList get_instance () {
        if (instance == null) {
            instance = new PagesList ();
        }

        return instance;
    }

    private PagesList () {
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
                found = ((PageItem) row).page.get_text ().down ().contains (this.search_for.down ());
            }

            return found;
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
        minus_button = new Gtk.Button.from_icon_name ("edit-delete-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
        notebook_name = new Gtk.Label ("");
        page_total = new Gtk.Label ("");
        separator = new Gtk.Separator (Gtk.Orientation.VERTICAL);

        minus_button.get_style_context ().add_class ("flat");
        plus_button.get_style_context ().add_class ("flat");

        notebook_name.halign = Gtk.Align.START;
        page_total.halign = Gtk.Align.END;
        minus_button.halign = Gtk.Align.END;
        minus_button.visible = false;
        separator.visible = false;
        notebook_name.hexpand = true;
        minus_button.can_focus = false;
        plus_button.can_focus = false;
        minus_button.no_show_all = true;
        separator.no_show_all = true;

        notebook_name.ellipsize = Pango.EllipsizeMode.END;
        notebook_name.get_style_context ().add_class ("h4");
        notebook_name.margin_left = 6;
        notebook_name.margin_right = 6;
        page_total.margin_right = 6;

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
        var childerns = listbox.get_children ();

        foreach (Gtk.Widget child in childerns) {
            if (child is Gtk.ListBoxRow)
                listbox.remove (child);
        }
    }

    private void refresh () {
        current_notebook.refresh ();
        load_pages (current_notebook);
    }

    public void select_page (ENotes.Page page) {
        var childerns = listbox.get_children ();

        foreach (Gtk.Widget child in childerns) {
            if (child is ENotes.PageItem) {
                var item = child as ENotes.PageItem;

                if (page.equals (item.page))
                    listbox.select_row (item);
            }
        }
    }

    public void load_pages (ENotes.Notebook notebook) {
        clear_pages ();
        this.current_notebook = notebook;
        notebook.refresh ();

        foreach (ENotes.Page page in notebook.pages) {
            new_page (page);
        }

        bool has_pages = notebook.pages.length () > 0;

        if (!has_pages) {
            var page = current_notebook.add_page_from_name (_("New Page"));
            var page_item = new ENotes.PageItem (page);

            listbox.prepend (page_item);
            listbox.show_all ();
        }

        toolbar.set_sensitive (true);
        minus_button.set_sensitive (false);
        page_total.label = _("%i Pages").printf(notebook.pages.length ());
        this.notebook_name.label = notebook.name.split ("§")[0] + ":";
        listbox.show_all ();
    }

    private ENotes.PageItem new_page (ENotes.Page page) {
        var page_box = new ENotes.PageItem (page);
        listbox.add (page_box);
        return page_box;
    }

    public void new_blank_page () {
        ENotes.Editor.get_instance ().save_file ();
        var page = current_notebook.add_page_from_name (_("New Page"));

        var page_item = new ENotes.PageItem (page);

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
            ENotes.Editor.get_instance ().reset (false);
            Headerbar.get_instance().set_title (null);

            var rows = listbox.get_selected_rows ();

            foreach (var row in rows) {
                ((ENotes.PageItem) row).trash_page ();
            }

            refresh ();
        });

        listbox.row_selected.connect ((row) => {
            if (row == null) return;

            minus_button.set_sensitive (true);
            ENotes.ViewEditStack.get_instance ().set_page (((ENotes.PageItem) row).page);
        });

        listbox.row_activated.connect ((row) => {
            window.toggle_edit ();

            if (ENotes.ViewEditStack.current_mode == Mode.EDIT)
                ENotes.Editor.get_instance ().give_focus ();
        });
    }
}
