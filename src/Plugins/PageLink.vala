/*
* Copyright (c) 2019 Felipe Escoto (https://github.com/Philip-Scott/Notes-up)
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

public class ENotes.PageLink : ENotes.Plugin {
    private PatternSpec spec = new PatternSpec ("*<page *>*");
    private Regex regex;

    construct {
        regex = new Regex ("<page\\s([0-9]+)\\s([^>]{1,})>");
    }

    public override string get_desctiption () {
        return _("Open a page in Notes-Up");
    }

    public override string get_name () {
        return _("Link to Page");
    }

    public override Gtk.Widget? editor_button () {
        return null;
    }

    // Action called by the editor when the button is pressed
    public override string request_string (string selection) {
        return selection;
    }

    public override string get_button_desctiption () {
        return "";
    }

    public override bool has_match (string text) {
        return spec.match_string (text);
    }

    public override string convert (string _line) {
        if (regex.match (_line, 0)) {
            return regex.replace_eval (_line, _line.length, 0, 0, (match_info, data) => {
                var page_id = int64.parse (match_info.fetch (1));

                data.append ("<a href=\"notes-up:///%lld\">".printf (page_id));
                data.append (match_info.fetch (2));
                data.append ("</a>");

                return false;
            });
        }

        return _line;
    }

    public override Gee.List<BLMember>? get_blacklist_members () {
        var list = new Gee.LinkedList<BLMember> ();
        list.add (new BLMember (/<page \d+>/, ""));
        return list;
    }
}
