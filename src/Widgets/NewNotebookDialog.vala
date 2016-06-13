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

public class ENotes.NotebookDialog : Gtk.Dialog {
    private Gtk.Entry name_entry;
    private Gtk.ColorButton color_button;
    private Gtk.ComboBox style_box;
    private Gtk.Button create;
    private Notebook? notebook;
    private Notebook? parent_nb;

    public NotebookDialog (Notebook? notebook = null) {
        this.notebook = notebook;
        build_ui ();
        connect_signals ();

        if (notebook != null) {
            load_data ();
            style_box.changed.connect (() => {
                save_notebook_style (notebook.path, style_box.active);
                ENotes.Viewer.get_instance ().reload ();
            });
        }

        this.show_all ();
    }

    public NotebookDialog.new_subnotebook (Notebook parent) {
        this ();
        parent_nb = parent;
    }

    public void build_ui () {
        this.set_border_width (12);
        set_keep_above (true);
        set_size_request (360, 280);
        resizable = false;
        modal = true;

        var main_box        = this.get_content_area();
        var title           = new Gtk.Label ("<b>%s</b>".printf (_("New Notebook")));
        var name_label      = new Gtk.Label (_("Name:"));
        var color_label     = new Gtk.Label (_("Color:"));
        var style_label     = new Gtk.Label (_("Style:"));

        title.set_use_markup (true);
        title.halign        = Gtk.Align.END;
        name_label.halign   = Gtk.Align.END;
        color_label.halign  = Gtk.Align.END;
        style_label.halign  = Gtk.Align.END;

        make_store ();

        name_entry = new Gtk.Entry ();
        add_button (_("Cancel"), 2);

        if (notebook != null) {
            title.set_label ("<b>%s</b>".printf (_("Edit Notebook")));

            Gdk.RGBA color = Gdk.RGBA ();
            color.red = notebook.r;
            color.green = notebook.g;
            color.blue = notebook.b;
            color.alpha = 1;

            color_button = new Gtk.ColorButton.with_rgba (color);
            create = (Gtk.Button) this.add_button (_("Edit"), 1);
        } else {
            color_button = new Gtk.ColorButton ();
            create = (Gtk.Button) this.add_button (_("Create"), 1);
            create.sensitive = false;
        }

        var grid = new Gtk.Grid ();
        grid.attach (title,			0,  0,  1,  1);
        grid.attach (name_label, 	0,	1, 	1,	1);
        grid.attach (name_entry,  	1,	1, 	1,	1);
        grid.attach (color_label, 	0,	2, 	1,	1);
        grid.attach (color_button, 	1,	2, 	1,	1);
        grid.attach (style_label, 	0,	3, 	1,	1);
        grid.attach (style_box, 	1,	3, 	1,	1);

        grid.set_column_homogeneous (false);
        grid.set_row_homogeneous (true);
        grid.margin_bottom = 12;
        grid.column_spacing = 12;
        grid.row_spacing = 6;

        main_box.add (grid);
    }

    private void make_store () {
        Gtk.ListStore list_store = new Gtk.ListStore (2, typeof (string), typeof (int));
		Gtk.TreeIter iter;

		int value = 0;
		foreach (string style in Viewer.STYLES) {
		    list_store.append (out iter);
		    list_store.set (iter, 0, style, 1, value);
		}

		// The Box:
		style_box = new Gtk.ComboBox.with_model (list_store);
		Gtk.CellRendererText renderer = new Gtk.CellRendererText ();
		style_box.pack_start (renderer, true);
		style_box.add_attribute (renderer, "text", 0);

		if (notebook != null) {
		    style_box.active = get_notebook_style (notebook);
		} else if (parent_nb != null) {
		    style_box.active = get_notebook_style (parent_nb);
		} else {
		    style_box.active = 0;
		}
    }

    private int get_notebook_style (Notebook notebook) {
        int active = 0;
        string value = Notebook.get_styleshet (notebook.path);

        foreach (string style in Viewer.STYLES) {
		    if (value == style) return active;
		    active++;
		}

        return 0;
    }

    private void save_notebook_style (string path, int selected) {
        stderr.printf ("Saving style %s %d\n", path, selected);
        if (selected == 0) {
            Notebook.set_styleshet (path, "default");
        } else {
            Notebook.set_styleshet (path, Viewer.STYLES[selected]);
        }
    }

    private void load_data () {
        name_entry.text = notebook.name;
    }

    private void connect_signals () {
        response.connect ((ID) => {
            switch (ID) {
                case 1: // Create Notebook
                    if (notebook == null) {
                        var r = color_button.rgba.red; var g = color_button.rgba.green; var b = color_button.rgba.blue;
                        if (parent_nb == null) {
                            string dir = FileManager.create_notebook (name_entry.text, r, g, b);
                            save_notebook_style (dir, style_box.active);
                        } else {
                            string dir = parent_nb.path + FileManager.create_notebook (name_entry.text, r, g, b, parent_nb.path);
                            save_notebook_style (dir, style_box.active);
                        }
                    } else {
                        Notebook? new_notebook = notebook.rename (name_entry.text, color_button.rgba);
                        if (new_notebook != null) {
                            save_notebook_style (new_notebook.path, style_box.active);
                        } else {
                            save_notebook_style (notebook.path, style_box.active);
                        }
                    }

                    ENotes.Sidebar.get_instance ().load_notebooks ();
                    ENotes.Sidebar.get_instance ().select_notebook (name_entry.text);
                    this.close ();
                    break;
                case 2: // Cancel
                    this.close ();
                    break;
            }
        });

        name_entry.notify["text"].connect (() => {
            if (name_entry.text == "" || name_entry.text.contains ("/") || name_entry.text.contains ("§")) {
                create.sensitive = false;
            } else {
                create.sensitive = true;
            }
        });


    }
}
