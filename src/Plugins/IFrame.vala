/*
* Copyright (c) 22016 Felipe Escoto (https://github.com/Philip-Scott/Notes-up)
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

public class ENotes.IFrame : ENotes.Plugin {
    private PatternSpec spec = new PatternSpec ("*<web *>*");
    private Gtk.Popover popover;

    private Gtk.Entry entry;

    construct {

    }

    public bool is_active () {
        return true;
    }

    public override string get_desctiption () {
        return _("Insert a webpage: <web [website]>");
    }

    public override string get_name () {
        return _("Web Frame");
    }

    public override Gtk.Widget? editor_button () {
        var image = new Gtk.Image.from_icon_name ("window-new", Gtk.IconSize.SMALL_TOOLBAR);

        popover = new Gtk.Popover (image);
        popover.position = Gtk.PositionType.BOTTOM;

        var grid = new Gtk.Grid ();
        grid.column_spacing = 6;
        grid.margin = 3;

        var label = new Gtk.Label (_("Website:"));
        label.get_style_context ().add_class ("h4");

        entry = new Gtk.Entry ();

        entry.activate.connect (() => {
            popover.hide ();

            unowned string str = entry.get_text ();
            string_cooked ("<web " + str + ">");
        });

        grid.add (label);
        grid.add (entry);
        popover.add (grid);

        return image;
    }

    public override string request_string (string selection) {
        popover.show_all ();
        entry.text = selection;

        return "";
    }

    public override string get_button_desctiption () {
        return _("Insert a Website");
    }

    public override bool has_match (string text) {
        return spec.match_string (text);
    }

    public override string convert (string line_) {
        int chars = line_.length;
        string line = line_ + "     ";
        string builed = "";

        int initial = 0, final = 0, last = 0;
        int i;
        for (i = -1; i < chars; ++i) {
            if (line[i] == '<') initial = i;
            else if (line[i] == '>') {
                final = i;
                string cut = line[initial:final];
                if (cut.contains ("<web ")) {
                    builed = builed + line [last:initial] + cut.replace ("<web ", "<iframe src=\"") + "\" style=\"width: 100%; height: 500px\"> </iframe>";
                    last = final +1;

                }
            }
        }

        return builed + line[last:i];
    }
}
