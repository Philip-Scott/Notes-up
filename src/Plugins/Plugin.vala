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

public abstract class ENotes.Plugin : GLib.Object {
    protected bool state = true;

    protected string code_name = "";

    // Editor after string is requested
    public signal void string_cooked (string text);


    // Description of the plugin
    public abstract string get_desctiption ();

    // Plugin name
    public abstract string get_name ();

    // What the module looks for in order to convert
    public abstract bool has_match (string text);

    // Once the viewer finds the key, it will call this function
    public abstract string convert (string line);

    // Widget that will be placed on a button on the text editor.
    public abstract Gtk.Widget? editor_button ();

    public virtual string get_button_desctiption () {
        return get_desctiption ();
    }

    // Action called by the editor when the button is pressed
    public virtual string request_string (string selection) {
        return selection;
    }
}
