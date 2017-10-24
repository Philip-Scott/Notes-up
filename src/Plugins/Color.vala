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

public class ENotes.Color : ENotes.Plugin {
    private PatternSpec spec = new PatternSpec ("*<color *>*");

    private Gtk.ColorChooserWidget color_selector;
    private Gtk.Popover popover;

    private string selection;

    construct {
        code_name = "ENOTES.COLORS";
    }

    public override string get_desctiption () {
        return _("Set font color for the line with <color [#color]> or for some text with <color [color] [text]>");
    }

    public override string get_name () {
        return _("Font color");
    }

    public override Gtk.Widget? editor_button () {
        var image = new Gtk.Image.from_icon_name ("applications-graphics", Gtk.IconSize.SMALL_TOOLBAR);

        popover = new Gtk.Popover (image);
        color_selector = new Gtk.ColorChooserWidget ();
        color_selector.margin = 6;

        popover.add (color_selector);

        popover.hide.connect (() => {
            color_selector.show_editor = false;
        });

        color_selector.color_activated.connect (() =>{
            popover.hide ();

            if (this.selection.length > 0) {
                string_cooked ("<color " + color_selector.get_rgba ().to_string () + " "+ this.selection + ">");
            } else {
                string_cooked ("<color " + color_selector.get_rgba ().to_string () + ">");
            }
        });
        return image;
    }

    public override string get_button_desctiption () {
        return _("Font color");
    }

    public override string request_string (string selection) {
        popover.show_all ();
        this.selection = selection;

        return "";
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
                if (cut.contains ("<color ")) {
                    var index = cut.index_of_char (' ', 7);
                    if (index == -1) { // simple Convertion
                        builed = builed + line [last:initial] + cut.replace ("<color ", "<color style=\"color:") + "\"";
                        last = final;
                    } else { // <color #xxx text>
                        builed = builed + line [last:initial] + cut[0:index].replace ("<color ", "<color style=\"color:") + "\">" + cut[index:cut.length] + "</color>";
                        last = final +1;
                    }
                }
            }
        }

        return builed + line[last:i];
    }
    
    public override Gee.List<BLMember> get_blacklist_members () {
        var list = new Gee.LinkedList<BLMember> ();
        list.add (new BLMember (/<color #[\d\p{L}]{6}>/, ""));
        return list;
    }
}
