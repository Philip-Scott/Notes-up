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
    public ENotes.Page page;

    private Gtk.Grid grid;
    private Gtk.Label name_label;
    private Gtk.Label preview_label;
    private Gtk.Label date_label;
    private DateTime time;
    private string date_formatted;

    public PageItem (ENotes.Page page) {
        this.page = page;
        build_ui ();
    }

    private void build_ui () {
        set_activatable (true);

        var margin_horizontal = 10;

        grid = new Gtk.Grid ();
        grid.orientation = Gtk.Orientation.VERTICAL;

        name_label = new Gtk.Label ("");
        name_label.use_markup = true;
        name_label.halign = Gtk.Align.START;
        name_label.get_style_context ().add_class ("title-label");
        name_label.ellipsize = Pango.EllipsizeMode.END;
        ((Gtk.Misc) name_label).xalign = 0;
        name_label.margin_top = 10;
        name_label.margin_left = margin_horizontal;
        name_label.margin_right = margin_horizontal;
        name_label.margin_bottom = 4;

        preview_label = new Gtk.Label ("");
        preview_label.halign = Gtk.Align.START;
        preview_label.margin_left = margin_horizontal;
        preview_label.margin_right = margin_horizontal;
        preview_label.margin_bottom = 4;
        preview_label.use_markup = true;
        preview_label.set_line_wrap (true);
        preview_label.ellipsize = Pango.EllipsizeMode.END;
        ((Gtk.Misc) preview_label).xalign = 0;
        preview_label.get_style_context ().add_class ("preview-label");
        preview_label.lines = 1;

        date_label = new Gtk.Label ("");
        date_label.halign = Gtk.Align.START;
        date_label.margin_left = margin_horizontal;
        date_label.margin_right = margin_horizontal;
        date_label.margin_bottom = 10;
        date_label.set_line_wrap (true);
        date_label.ellipsize = Pango.EllipsizeMode.END;
        ((Gtk.Misc) date_label).xalign = 0;
        date_label.get_style_context ().add_class ("date-time-label");
        date_label.lines = 1;

        var separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
        separator.hexpand = true;

        this.add (grid);
        grid.add (name_label);
        grid.add (preview_label);
        grid.add (date_label);
        grid.add (separator);

        load_data ();
        this.show_all ();
    }

    public void trash_page () {
        this.destroy ();
    }

    public void load_data () {
        time = new DateTime.from_unix_utc (page.modification_date);
        //if (ENotes.Application.clock_format == "24h") {
        //    date_formatted = time.format (_("%a, %e %b %y, %H:%M")).strip ();
        //} else {
        //    date_formatted = time.format (_("%a, %e %b %y, %l:%M %p")).strip ();
        //}

        date_formatted = "placeholder";
        this.date_label.label = date_formatted;
        this.preview_label.label = page.subtitle;
        this.name_label.label = page.name;
    }
}

