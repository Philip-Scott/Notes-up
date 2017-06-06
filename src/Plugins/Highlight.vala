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

public class ENotes.Highlight : ENotes.Plugin {
    private PatternSpec spec = new PatternSpec ("*<highlight>*");

    construct {}

    public override string get_desctiption () {
        return _("Enable Syntax Highlighing");
    }

    public override string get_name () {
        return _("Syntax Highlighing");
    }

    public override Gtk.Widget? editor_button () {
        return null;
    }

    // Action called by the editor when the button is pressed
    public override string request_string (string selection) {
        string_cooked ("<highlight>");
        return selection;
    }

    public override string get_button_desctiption () {
        return "";
    }

    public override bool has_match (string text) {
        return spec.match_string (text);
    }

    public override string convert (string line_) {
        return line_.replace ("<highlight>", """<link rel="stylesheet" href="/usr/share/notes-up/solarized-light.css">
<script src="/usr/share/notes-up/highlight.pack.js"></script>
<script>hljs.initHighlightingOnLoad();</script>""");
    }
}
