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

namespace ENotes {
    public ENotes.Services.Settings settings;
    public ENotes.Window window;
    public string NOTES_DIR;
}

public class ENotes.Application : Gtk.Application {
    public const string PROGRAM_NAME = N_("Notes-up");
    public const string COMMENT = N_("Your Markdown Notebook.");
    public const string ABOUT_STOCK = N_("About Notes");

    public bool running = false;

    public Application () {
        Object (application_id: "org.notes");
    }

    public override void activate () {
        if (!running) {
            settings = ENotes.Services.Settings.get_instance ();
            if (settings.notes_location == "") {
                settings.notes_location = GLib.Environment.get_home_dir () + "/.notes/";
            }

            ENotes.NOTES_DIR = settings.notes_location;

            window = new ENotes.Window (this);
            this.add_window (window);

            running = true;
        }

        window.show_app ();
    }
}
