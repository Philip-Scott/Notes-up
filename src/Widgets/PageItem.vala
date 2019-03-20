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

public class ENotes.PageItem : Gtk.ListBoxRow {
    public ENotes.Page page { get; construct set; }

    private Gtk.Grid grid;
    private Gtk.Label title_label;
    private Gtk.Label preview_label;

    public PageItem (ENotes.Page page) {
        Object (page: page);
    }

    private static Trash trash_instance;

    static construct {
        trash_instance = Trash.get_instance ();
    }

    construct {
        set_activatable (true);

        grid = new Gtk.Grid ();
        grid.orientation = Gtk.Orientation.VERTICAL;

        title_label = new Gtk.Label ("");
        title_label.use_markup = true;
        title_label.halign = Gtk.Align.START;
        title_label.get_style_context ().add_class ("h3");
        title_label.ellipsize = Pango.EllipsizeMode.END;
        ((Gtk.Misc) title_label).xalign = 0;
        title_label.margin_top = 10;
        title_label.margin_start = 10;
        title_label.margin_end = 10;
        title_label.margin_bottom = 8;

        preview_label = new Gtk.Label ("");
        preview_label.halign = Gtk.Align.START;
        preview_label.margin_top = 0;
        preview_label.margin_start = 10;
        preview_label.margin_end = 10;
        preview_label.margin_bottom = 10;
        preview_label.use_markup = true;
        preview_label.set_line_wrap (true);
        preview_label.ellipsize = Pango.EllipsizeMode.END;
        ((Gtk.Misc) preview_label).xalign = 0;
        preview_label.lines = 3;

        var separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
        separator.hexpand = true;

        this.add (grid);
        grid.add (title_label);
        grid.add (preview_label);
        grid.add (separator);

        load_data ();
        this.show_all ();
    }

    public void load_data () {
        preview_label.label = page.subtitle;
        title_label.label = "<b>" + page.name + "</b>";

        title_label.sensitive = !trash_instance.is_page_trashed (page);
        preview_label.sensitive = title_label.sensitive;
    }
}
