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

public class ENotes.Page : Object {
    public signal void saved_file ();
    public signal void destroy ();

    public string name  { public get; private set; }
    public string subtitle { public get; private set; }
    public string full_path { public get; private set; } //File's location + full name
    public string path { public get; private set; } //This file's location
    public int date { public get; private set; }
    public int ID = -1;
    public bool new_page = false;

    private string? page_data = null;

    private File file { public get; private set; }

    public Page (string path) {
        full_path = path;
        file = File.new_for_path (full_path);

        if (!file.query_exists ()) {
            new_page = true;
        }

        var l = full_path.length;
        var ln = l - file.get_basename ().length;

        this.path = full_path.slice(0, ln);

        get_text ();
        load_page_info ();
    }

    private void load_page_info () {
        string line;
        string[] lines;
        this.subtitle = "";

        lines = page_data.split ("\n");

        string t_name = file.get_basename ();
        if (t_name.contains ("§")) {
            var split = t_name.split ("§", 2);

            ID = int.parse (split[0]);
        }

        if (lines.length > 0) {
            name = cleanup(lines[0]);

            for(int n = 0, i = 1; i < lines.length && n < 150; i++) {
                line = cleanup (lines[i]);
                if (line != "") {
                    if (line.length + n > 150)
                        this.subtitle = this.subtitle + line[0:150 - n] + " ";
                    else
                        this.subtitle = this.subtitle + line + " ";
                    n = n + line.length;
                }
            }
        } else {
            name = _("New Page");
            new_page = true;
        }
    }

    public string get_text (bool force_load = false) {
        debug ("Getting text");
        if (new_page) {
            return "";
        } if (page_data == null || force_load) {
            debug ("Loading from file");
            try {
                var dis = new DataInputStream (this.file.read ());
                size_t size;
                this.page_data = dis.read_upto ("\0", -1, out size);
            } catch (Error e) {
                warning ("Error loading file: %s", e.message);
            }
        }

        return page_data;
    }

    public void save_file (string data) {
        if (data == "") {
            trash_page ();
            return;
        }

        string file_name = make_filename ();

        try {
            this.file = File.new_for_path (path + file_name);
            FileManager.write_file (file, data, true);
            this.full_path = file.get_path ();
            new_page = false;
        } catch (Error e) {
            warning ("Error Saving file: %s", e.message);
        }

        this.page_data = data;
        load_page_info ();
        this.saved_file ();
    }

    public void delete () {
        try {
            file.trash ();
        } catch (Error e) {
            warning ("Error trashing file: %s", e.message);
        }
    }

    public void trash_page () {
        Trash.get_instance ().trash_page (this);
        this.destroy ();
    }

    public bool move_page (Notebook destination) {
        try {
            file.move (destination.directory, FileCopyFlags.NONE);
        } catch (Error e) {
            warning ("Moving page failed: %s", e.message);
            return false;
        }

        return true;
    }

    private string cleanup (string line) {
        string output = line;

        if (line.contains ("---")) return "";

        string[] blacklist = {"#", "```", "\t", ">", "<", "\n"};
        foreach (string item in blacklist) {
            if (output.contains (item)) {
                output = output.replace (item, "");
            }
        }

        if (output.contains ("&")) output = output.replace ("&","&amp;");

        if (output.length > 0 && output[0] == ' ') {
            output = output[1:output.length];
        }

        return output;
    }

    private string make_filename () {
        string file_name;

        if (new_page) {
            file_name = ENotes.Editor.get_instance ().get_text ().split ("\n", 2)[0];
            file_name = clean_filename (file_name);
            return ID.to_string () + "§" + file_name;
        } else {
            return file.get_basename ();
        }
    }

    private string clean_filename (string file) {
        string file_name = file;

        string[] blacklist = {"\\", "/", "%", "|", ":", "<",">", "§", "*", "&", "?", "#"};
        foreach (string item in blacklist) {
            if (file_name.contains (item))
                file_name = file_name.replace (item, "");
        }

        return file_name;
    }

    public bool equals (ENotes.Page comp) {
        return this.full_path == comp.full_path;
    }

    public bool is_bookmarked () {
        var link = ENotes.NOTES_DIR + full_path.replace (ENotes.NOTES_DIR, "").replace ("/", ".");
        var file = File.new_for_path (link);

        return file.query_exists ();
    }
}
