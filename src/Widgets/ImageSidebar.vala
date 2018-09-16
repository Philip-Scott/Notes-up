/*
* Copyright (c) 2018 Felipe Escoto (https://github.com/Philip-Scott/Notes-up)
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

public class ENotes.ImageSidebar : Gtk.Grid {

    private Page _current_page;
    public Page current_page {
        get {
            return _current_page;
        }

        set {

        }
    }

    private bool _enabled;
    public bool enabled {
        get {
            return _enabled;
        }

        set {

        }
    }
}


public class ENotes.ImageHandler : Object {
    public static uint FILE_ID = 0;

    public signal void file_changed ();

    private uint file_id;

    const string FILENAME = "/notes-up-%s-img-%u.%s";

    private FileMonitor? monitor = null;
    private bool file_changing = false;

    public bool valid = false;
    private string? base64_image = null;

    public string image_extension { get; private set; }

    private string url_ = "";
    public string url {
        get {
            return url_;
        } set {
            url_ = value;
            var file = File.new_for_path (value);
            monitor_file (file);
            valid = (file.query_exists () && Utils.is_valid_image (file));
            file_changed ();
        }
    }

    public ImageHandler.from_data (string _extension, string _base64_data) {
        file_id = FILE_ID++;
        image_extension = _extension != "" ? _extension : "png";
        base64_image = _base64_data;
        url = data_to_file (_base64_data);
    }

    public ImageHandler.from_file (File file) {
        file_id = FILE_ID++;
        replace (file);
    }

    public void replace (File file) {
        if (monitor != null) {
            monitor.cancel ();
        }

        image_extension = get_extension (file.get_basename ());
        data_from_file (file);
        url = data_to_file (base64_image);
    }

    public string serialize () {
        return """"image":"%s", "image-data":"%s" """.printf (image_extension, base64_image);
    }

    private void monitor_file (File file) {
        try {
            monitor = file.monitor (FileMonitorFlags.NONE, null);

            monitor.changed.connect ((src, dest, event) => {
                if (event == FileMonitorEvent.CHANGED) {
                    file_changing = true;
                } else if (event == FileMonitorEvent.CHANGES_DONE_HINT && file_changing) {
                    data_from_file (file);
                    file_changed ();
                    file_changing = false;
                }
            });
        } catch (Error e) {
            warning ("Could not monitor file: %s", e.message);
        }
    }

    private string get_extension (string filename) {
        var parts = filename.split (".");
        if (parts.length > 1) {
            return parts[parts.length - 1];
        } else {
            return "png";
        }
    }

    private void data_from_file (File file) {
        base64_image = Spice.Services.FileManager.file_to_base64 (file);
    }

    private string data_to_file (string data) {
        var filename = Environment.get_tmp_dir () + FILENAME.printf (Environment.get_user_name (), file_id, image_extension);
        Spice.Services.FileManager.base64_to_file (filename, data);

        return filename;
    }
}
