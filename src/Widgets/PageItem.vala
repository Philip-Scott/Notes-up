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
    private Gtk.Label line1;
    private Gtk.Label line2;
    private Gtk.Label line3;
    private DateTime time;
    private string date_string;

    public PageItem (ENotes.Page page) {
        this.page = page;
        build_ui ();
    }

    private void build_ui () {
        set_activatable (true);

        grid = new Gtk.Grid ();
        grid.orientation = Gtk.Orientation.VERTICAL;

        line1 = new Gtk.Label ("");
        line1.use_markup = true;
        line1.halign = Gtk.Align.START;
        line1.get_style_context ().add_class ("h3");
        line1.ellipsize = Pango.EllipsizeMode.END;
        ((Gtk.Misc) line1).xalign = 0;
        line1.margin_top = 4;
        line1.margin_left = 8;
        line1.margin_right = 8;
        line1.margin_bottom = 4;

        line2 = new Gtk.Label ("");
        line2.halign = Gtk.Align.START;
        line2.margin_left = 8;
        line2.margin_right = 8;
        line2.margin_bottom = 4;
        line2.use_markup = true;
        line2.set_line_wrap (true);
        line2.ellipsize = Pango.EllipsizeMode.END;
        ((Gtk.Misc) line2).xalign = 0;
        line2.get_style_context ().add_class (Gtk.STYLE_CLASS_DIM_LABEL);
        line2.lines = 3;

        line3 = new Gtk.Label ("");
        line3.halign = Gtk.Align.START;
        line3.margin_left = 8;
        line3.margin_right = 8;
        line3.margin_bottom = 4;
        line3.set_line_wrap (true);
        line3.ellipsize = Pango.EllipsizeMode.END;
        ((Gtk.Misc) line3).xalign = 0;
        line3.get_style_context ().add_class (Gtk.STYLE_CLASS_DIM_LABEL);
        line3.lines = 3;

        var separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
        separator.hexpand = true;

        this.add (grid);
        grid.add (line1);
        grid.add (line2);
        grid.add (line3);
        grid.add (separator);

        load_data ();
        this.show_all ();
    }

    public void trash_page () {
        this.destroy ();
    }

    public void load_data () {
        time = new DateTime.from_unix_utc (page.modification_date);

        if (use24HSFormat) {
            date_string = time.format ("%H:%M, %a, %e %b %Y");
        } else {
            date_string = time.format ("%l:%M %p, %a, %e %b %Y");
        }
        date_string = date_string.chug ();
        this.line3.label = date_string;
        this.line2.label = page.subtitle;
        this.line1.label = "<b>" + page.name + "</b>";
    }
}

