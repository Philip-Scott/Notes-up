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

public class ENotes.Services.Settings : Granite.Services.Settings {
    private static Settings? instance = null;

    public int pos_x { get; set; }
    public int pos_y { get; set; }
    public int window_width { get; set; }
    public int window_height { get; set; }
    public int panel_size { get; set; }
    public int notebook_panel_size { get; set; }
    public int mode { get; set; }
    public int last_notebook { get; set; }
    public int last_page { get; set; }

    public bool auto_indent {get; set;}
    public bool line_numbers {get; set;}
    public bool import_files {get; set;}
    public bool keep_sidebar_visible { get; set; }
    public bool spellcheck { get; set; }
    public bool show_page_info { get; set; }

    public string notes_location { get; set; }
    public string notes_database { get; set; }
    public string editor_font { get; set; }
    public string editor_scheme { get; set; }
    public string render_stylesheet { get; set; }
    public string stylesheet { get; set; }
    public string spellcheck_language { get; set; }

    public static Settings get_instance () {
        if (instance == null) {
            instance = new Settings ();
        }

        return instance;
    }

    private Settings () {
        base ("org.notes");
    }
}
