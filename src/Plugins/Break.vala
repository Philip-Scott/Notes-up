/*
* Copyright (c) 2017 Felipe Escoto (https://github.com/Philip-Scott/Notes-up)
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

public class ENotes.Break : ENotes.Plugin {
    private PatternSpec spec = new PatternSpec ("*<break>*");

    construct {}

    public override string get_desctiption () {
        return _("Page break when exporting to PDF: <break>");
    }

    public override string get_name () {
        return _("Page break");
    }

    public override Gtk.Widget? editor_button () {
        var image = new Gtk.Image.from_icon_name ("emblem-documents", Gtk.IconSize.SMALL_TOOLBAR);
        return image;
    }

    // Action called by the editor when the button is pressed
    public override string request_string (string selection) {
        string_cooked ("<break>");
        return selection;
    }

    public override string get_button_desctiption () {
        return _("Page break on export: <break>");
    }

    public override bool has_match (string text) {
        return spec.match_string (text);
    }

    public override string convert (string line_) {
        return line_.replace ("<break>", """<div style="page-break-after: always;">&zwnj;</div>""");
    }
}
