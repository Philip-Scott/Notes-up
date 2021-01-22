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

public class ENotes.Mathjax : ENotes.Plugin {
    private PatternSpec spec = new PatternSpec ("*<mathjax>*");

    construct {}

    public override string get_desctiption () {
        return _("Enable LateX Formulation");
    }

    public override string get_name () {
        return _("LateX Math");
    }

    public override Gtk.Widget? editor_button () {
        return null;
    }

    // Action called by the editor when the button is pressed
    public override string request_string (string selection) {
        string_cooked ("<mathjax>");
        return selection;
    }

    public override string get_button_desctiption () {
        return "";
    }

    public override bool has_match (string text) {
        return spec.match_string (text);
    }

    public override string convert (string line_) {
        return line_.replace ("<mathjax>",
        """<script src="/usr/share/notes-up/load-mathjax.js" async></script>""");
    }

    public override Gee.List<BLMember>? get_blacklist_members () {
        var list = new Gee.LinkedList<BLMember> ();
        list.add (new BLMember (/<mathjax>/, ""));
        return list;
    }
}
