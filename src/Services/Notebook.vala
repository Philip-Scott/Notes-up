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

public class ENotes.Notebook : Object {
    private static const string CHILD_SCHEMA_ID = "org.notes.notebook_data.notebook";
    private static const string CHILD_PATH = "/org/notes/notebook_data/notebook/%s";
    private static Gee.HashMap<string, Settings> notebook_settings_cache = new Gee.HashMap<string, Settings> ();

    public signal void destroy ();

    public string name { public get; private set; }
    public string path { public get; private set; }
    public File directory { public get; private set; }

    public List<ENotes.Page> pages;
    public List<ENotes.Notebook> sub_notebooks;

    public double r { public get; public set; default = -1; }
    public double g { public get; public set; default = -1; }
    public double b { public get; public set; default = -1; }

    public int top_id = 0;

    public Notebook (string path_) {
        this.path = path_ + "/";
        this.path = this.path.replace ("//", "/");
        directory = File.new_for_path (path);

        split_string ();
        debug ("Making notebook for %s", name);
        pages = new List<ENotes.Page> ();
        sub_notebooks = new List<ENotes.Notebook> ();
    }

    public void refresh () {
        debug ("Refreshing notebook: %s", name);

        this.pages = new List<ENotes.Page> ();
        load_pages ();
    }

    public ENotes.Page add_page_from_name (string path) {
        var page = new ENotes.Page (this.path + path);
        add_page (page);

        return page;
    }

    public void load_pages () {
        debug ("Loading pages for notebook: %s", name);

        try {
            var directory = File.new_for_path (path);
            var enumerator = directory.enumerate_children (FileAttribute.STANDARD_NAME, 0);
            FileInfo file_info;

            while ((file_info = enumerator.next_file ()) != null) {
                if (file_info.get_file_type () == FileType.DIRECTORY) {
                    var notebook = new ENotes.Notebook (file_info.get_name ());
                    sub_notebooks.append (notebook);
                } else {
                    add_page_from_name (file_info.get_name ());
                }
            }
        } catch (Error e) {
            warning ("Could not load pages: %s",e.message);
        }
    }

    public ENotes.Notebook? rename (string new_name, Gdk.RGBA rgba) {
        var new_r = double.parse (rgba.red.to_string());
        var new_g = double.parse (rgba.green.to_string());
        var new_b = double.parse (rgba.blue.to_string());

        if (this.name == new_name && new_r == r && new_b == b && new_g == g)
            return null;

        string nname = "%s§%s§%s§%s".printf(new_name, new_r.to_string(), new_g.to_string(), new_b.to_string());

        try {
            directory = directory.set_display_name (nname);
        } catch (Error e) {
            warning ("Error renaming directory: %s", e.message);
        }

        var notebook = new ENotes.Notebook (this.path + nname);

        return notebook;
    }

    CompareDataFunc<Page> page_comp = (a, b) => {
        int d = (int) (a.ID < b.ID) - (int) (a.ID > b.ID);
        return d;
    };

    public void add_page (Page page) {
        if (Trash.get_instance ().is_page_trashed (page)) return;

        this.pages.insert_sorted_with_data (page, page_comp);

        if (top_id < page.ID) {
            top_id = page.ID;
        }

        if (page.new_page) {
            page.ID = ++top_id;
        }
    }

    // Null == ROOT
    public void move_notebook (Notebook? parent) {
        try {
            File destination;
            if (parent == null) {
                destination = File.new_for_path (ENotes.NOTES_DIR);
            } else {
                destination = parent.directory;
            }

            directory.move (destination, FileCopyFlags.NONE);
        } catch (Error e) {
            warning ("Could not move directory: %s", e.message);
        }

        this.destroy ();
    }

    public void trash () {
        Trash.get_instance ().trash_notebook (this);
        this.destroy ();
    }

    public void delete () {
        try {
            directory.trash ();
        } catch (Error e) {
            warning ("Error trashing file: %s", e.message);
        }
    }

    private void split_string () {
        var split = directory.get_basename ().split ("§", 4);
        name = split[0].replace (ENotes.NOTES_DIR, "");
        if (split.length > 3) {
            r = double.parse (split[1]);
            g = double.parse (split[2]);
            b = double.parse (split[3]);
        }
    }

    private static Settings get_settings (string notebook_path) {
        var notebook_id = notebook_path.replace (NOTES_DIR, "").replace ("/", "") + "/";
        Settings? notebook_settings = notebook_settings_cache.get (notebook_id);

        if (notebook_settings == null) {
            var schema = SettingsSchemaSource.get_default ().lookup (CHILD_SCHEMA_ID, false);
		    if (schema != null) {
			    notebook_settings = new Settings.full (schema, null, CHILD_PATH.printf (notebook_id));
			    notebook_settings_cache.set (notebook_id, notebook_settings);
                notebook_settings = new Settings.full (SettingsSchemaSource.get_default ().lookup (CHILD_SCHEMA_ID, true), null, CHILD_PATH.printf (notebook_id));
            } else {
                warning ("Getting notebook schema failed");
            }
        }

        return notebook_settings;
    }

    public static string get_styleshet (string notebook_path) {
        var notebook_settings = get_settings (notebook_path);
        return notebook_settings.get_string ("stylesheet");
    }

    public static void set_styleshet (string notebook_path, string style) {
        var notebook_settings = get_settings (notebook_path);
        notebook_settings.set_string ("stylesheet", style);
    }

    public static string get_styleshet_changes (string notebook_path) {
        var notebook_settings = get_settings (notebook_path);
        return notebook_settings.get_string ("stylesheet-changes");
    }

    public static void set_styleshet_changes (string notebook_path, string style) {
        var notebook_settings = get_settings (notebook_path);
        notebook_settings.set_string ("stylesheet-changes", style);
    }
}
