/*
* Copyright (c) 2016 Felipe Escoto (https://github.com/Philip-Scott/Notes-up)
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

public class ENotes.Youtube : ENotes.Plugin {
    private PatternSpec spec = new PatternSpec ("*<youtube *>*");

    construct {

    }

    public override string get_desctiption () {
        return _("Embed youtube videos: <youtube [video]>");
    }

    public override string get_name () {
        return _("Youtube");
    }

    public override Gtk.Widget? editor_button () {
        return null;
    }

    public override string get_button_desctiption () {
        return _("Insert Youtube video");
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
                if (cut.contains ("<youtube ")) {
                    var index = cut.index_of ("v=", 0);

                    builed = builed + line [last:initial] + "<iframe width=\"560\" height=\"315\" src=\"https://www.youtube.com/embed/" + cut[index + 2:index + 13] + "\" frameborder=\"0\" allowfullscreen></iframe>";

                    last = final +1;
                }
            }
        }

        return builed + line[last:i];
    }
}
