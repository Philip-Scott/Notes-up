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

public class ENotes.StyleLoader {
    public static string[] STYLES = {_("Default"), "elementary", "Air", "Modest"};
    private const string RESOURCE_PATH = "resource:///com/github/philip-scott/notes-up/styles/%s.css";

    private static ENotes.StyleLoader? _instance = null;
    public static ENotes.StyleLoader instance {
        get {
            if (_instance == null) {
                _instance = new ENotes.StyleLoader ();
            }

            return _instance;
        }
    }

    public string get_styleshet (string? stylesheet, int64 current_page_id, bool trying_global = false) {
        string css;

        if (stylesheet == null) stylesheet = "";

        switch (stylesheet) {
            case "elementary":
            case "Modest":
            case "Air":
                var file = File.new_for_uri (RESOURCE_PATH.printf (stylesheet));
                css = get_data (file);
                break;
            default:
                if (trying_global == false) {
                    css = get_styleshet (ENotes.settings.stylesheet, current_page_id, true);
                } else {
                    var file = File.new_for_uri (RESOURCE_PATH.printf ("elementary"));
                    css = get_data (file);
                }
            break;
        }

        if (!trying_global) {
            return css + ENotes.settings.render_stylesheet + NotebookTable.get_instance ().get_css_from_page (current_page_id);
        }

        return css;
    }

    private static string get_data (File file) {
        try {
            var dis = new DataInputStream (file.read ());
            size_t size;

            return dis.read_upto ("\0", -1, out size);
        } catch (Error e) {
            warning ("Could not load from gresource %s", e.message);
            return "";
        }
    }
}