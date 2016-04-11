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
    private ENotes.Headerbar headerbar;

    private Gtk.ListBox listbox;
    private Gtk.Frame toolbar;

    private Gtk.Separator separator;
    private Gtk.Button minus_button;
    private Gtk.Button plus_button;
    private Gtk.Label notebook_name;
    private Gtk.Label page_total;

    public ENotes.Notebook current_notebook;

    private string search_for = "";

    public PagesList (ENotes.Headerbar headerbar) {
        this.headerbar = headerbar;

        build_ui ();
        connect_signals ();
    }

    private void build_ui () {
        orientation = Gtk.Orientation.VERTICAL;

        var scroll_box = new Gtk.ScrolledWindow (null, null);
        listbox = new Gtk.ListBox ();
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
        listbox.vexpand = true;
        toolbar = build_toolbar ();

        scroll_box.add (listbox);
        this.add (scroll_box);
        this.add (toolbar);
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
        page_total.label = @"$(notebook.pages.length ()) Pages";
        this.notebook_name.label = notebook.name.split ("§")[0] + ":";
        listbox.show_all ();
    }

    private ENotes.PageItem new_page (ENotes.Page page) {
        var page_box = new ENotes.PageItem (page);
        listbox.add (page_box);

        return page_box;
    }

    public void new_blank_page () {
        editor.save_file ();
        var page = current_notebook.add_page_from_name (_("New Page"));
        page.new_page = true;

        var page_item = new ENotes.PageItem (page);

        editor.load_file (page);
        listbox.prepend (page_item);
        listbox.show_all ();
        listbox.select_row (page_item);
    }

    public new void grab_focus () {
        listbox.grab_focus ();
    }

    private void connect_signals () {
        headerbar.mode_changed.connect ((edit) => {
            minus_button.visible = edit;
            separator.visible = edit;
            page_total.visible = !edit;
        });

        headerbar.search_changed.connect (() => {
            this.search_for = headerbar.search_entry.get_text ();
            listbox.invalidate_filter ();
        });

        headerbar.search_selected.connect (() => {
            listbox.select_row (listbox.get_row_at_y (0));
            listbox.get_row_at_y (0).grab_focus ();
        });

        plus_button.clicked.connect (() => {
            new_blank_page ();
        });

        minus_button.clicked.connect (() => {
            editor.set_sensitive (false);
            editor.reset (false);
            headerbar.set_title (null);
            var row = listbox.get_selected_row ();
            ((ENotes.PageItem) row).trash_page ();
            refresh ();
        });

        listbox.row_selected.connect ((row) => {
            if (row == null) return;
            editor.load_file (((ENotes.PageItem) row).page);
        });

        listbox.row_activated.connect ((row) => {
            if (headerbar.get_mode () == 1)
                editor.give_focus ();
        });
    }
}
