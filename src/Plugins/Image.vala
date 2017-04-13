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

public class ENotes.ImagePlugin : ENotes.Plugin {
    private PatternSpec spec = new PatternSpec ("*<image *>*");

    construct {}

    public override bool is_active () {
        return true;
    }

    public override void set_active (bool active) {

    }

    public override string get_desctiption () {
        return _("Load an embeded image");
    }

    public override string get_name () {
        return _("Image");
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
        var image_table = ENotes.ImageTable.get_instance ();
        var image_id = int64.parse(_line.split ("<image ")[1].replace (">", ""));
        var page_id = ViewEditStack.get_instance ().current_page.id;
        var image = image_table.get_image (page_id, image_id);

        var data = new StringBuilder ();
        if (image != null) {
            data.append ("<img src=\'%s,".printf (ImageFormat.get_data (image.format)));
            data.append (image.data);
            data.append ("\'>");
        }

        return data.str;
    }
}
