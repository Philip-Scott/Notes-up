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
<<<<<<< HEAD

=======
>>>>>>> origin/master
public class ENotes.NotebookDialog : Gtk.Dialog {
	private Gtk.Entry name_entry;
	private Gtk.ColorButton color_button;
	private Gtk.Button create;
    private Notebook? notebook;
    private Notebook? parent_nb;

    public NotebookDialog (Notebook? notebook = null) {
        this.notebook = notebook;
        build_ui ();
        connect_signals ();

        if (notebook != null) {
            load_data ();
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

        var main_box 		= this.get_content_area();
		var title 			= new Gtk.Label ("<b>%s</b>".printf (_("New Notebook")));
		var name_label 		= new Gtk.Label ("Name:");
		var color_label	    = new Gtk.Label ("Color:");
		title.set_use_markup (true);
		title.halign 		= Gtk.Align.START;
		name_label.halign 	= Gtk.Align.START;
		color_label.halign 	= Gtk.Align.START;

		name_entry = new Gtk.Entry ();
		add_button ("Cancel", 2);

		if (notebook != null) {
            title.set_label ("<b>%s</b>".printf (_("Edit Notebook")));

		    Gdk.RGBA color = Gdk.RGBA ();
		    color.red = notebook.r;
		    color.green = notebook.g;
		    color.blue = notebook.b;
            color.alpha = 1;

		    color_button = new Gtk.ColorButton.with_rgba (color);
		    create = (Gtk.Button) this.add_button ("Edit", 1);
		} else {
		    color_button = new Gtk.ColorButton ();
		    create = (Gtk.Button) this.add_button ("Create", 1);
		    create.sensitive = false;
		}



		var grid = new Gtk.Grid ();
		grid.attach (title,			0,  0,  1,  1);
		grid.attach (name_label, 	0,	1, 	1,	1);
		grid.attach (name_entry,  	1,	1, 	1,	1);
		grid.attach (color_label, 	0,	2, 	1,	1);
		grid.attach (color_button, 	1,	2, 	1,	1);

		grid.set_column_homogeneous (false);
		grid.set_row_homogeneous (true);
		grid.row_spacing = 12;

		main_box.add (grid);
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
                            FileManager.create_notebook (name_entry.text, r, g, b);
                        } else {
                            FileManager.create_notebook (name_entry.text, r, g, b, parent_nb.path);
                        }
                    } else {
                        notebook.r = color_button.rgba.red;
                        notebook.g = color_button.rgba.green;
                        notebook.b = color_button.rgba.blue;

                        notebook.rename (name_entry.text);
                    }

    				sidebar.load_notebooks ();
    				this.close ();
    				break;
    			case 2: // Cancel
					this.close ();
    				break;
    		}
    	});

    	name_entry.notify["text"].connect (() => {
    		if (name_entry.text == "") {
    			create.sensitive = false;
    		} else {
    			create.sensitive = true;
    		}
    	});
    }
}
