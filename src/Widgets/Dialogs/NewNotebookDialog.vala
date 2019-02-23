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
    private Gtk.Stack stack;

    private Gtk.Entry name_entry;
    private Gtk.ColorButton color_button;
    private Gtk.ComboBox style_box;
    private Gtk.TextView style_changes;
    private Gtk.Button create;
    private Notebook? notebook;
    private Notebook? parent_nb;

    public NotebookDialog (Notebook? notebook = null) {
        this.notebook = notebook;
        set_transient_for (window);
        build_ui ();
        connect_signals ();

        if (notebook != null) {
            load_data ();
            style_box.changed.connect (() => {
                ENotes.Viewer.get_instance ().reload ();
            });
        }

        this.show_all ();
    }

    public NotebookDialog.new_subnotebook (Notebook parent) {
        this ();
        parent_nb = parent;
        style_box.active = get_notebook_style (parent_nb);
    }

    public void build_ui () {
        this.set_border_width (12);
        set_keep_above (true);
        set_size_request (360, 280);
        resizable = false;
        deletable = false;
        modal = true;

        var name_label = new Gtk.Label (_("Name:"));
        var color_label = new Gtk.Label (_("Color:"));

        name_label.halign  = Gtk.Align.END;
        color_label.halign = Gtk.Align.END;

        make_store ();

        name_entry = new Gtk.Entry ();
        add_button (_("Cancel"), 2);

        if (notebook != null) {
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
        grid.attach (name_label,   0, 1, 1, 1);
        grid.attach (name_entry,   1, 1, 1, 1);
        grid.attach (color_label,  0, 2, 1, 1);
        grid.attach (color_button, 1, 2, 1, 1);

        grid.set_column_homogeneous (false);
        grid.set_row_homogeneous (true);
        grid.margin_bottom = 12;
        grid.column_spacing = 12;
        grid.row_spacing = 6;
        grid.valign = Gtk.Align.START;

        stack = new Gtk.Stack ();
        stack.add_titled (grid, "properties", _("Properties"));
        stack.add_titled (viewer_grid (), "style", _("Style"));
        stack.set_margin_top (12);
        stack.set_margin_bottom (12);

        var switcher = new Gtk.StackSwitcher ();
        switcher.set_stack (stack);
        switcher.halign = Gtk.Align.CENTER;

        var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);

        box.add (switcher);
        box.add (stack);
        this.get_content_area().add (box);

        this.show_all ();
    }

    private Gtk.Grid viewer_grid () {
        var title = new Gtk.Label ("<b>%s</b>".printf(_("Style modifications")));
        title.set_use_markup (true);
        title.set_halign (Gtk.Align.START);

        style_changes = new Gtk.TextView ();
        style_changes.set_wrap_mode (Gtk.WrapMode.WORD);
        style_changes.set_hexpand (true);
        style_changes.set_vexpand (true);

        var scrolled = new Gtk.ScrolledWindow (null, null);
        scrolled.height_request = 90;
        scrolled.add (style_changes);

        var styles_label = new Gtk.Label (_("Stylesheet:"));
        styles_label.set_halign (Gtk.Align.END);
        make_store ();

        var grid = new Gtk.Grid ();
        grid.set_column_homogeneous (false);
        grid.set_row_homogeneous (false);
        grid.row_spacing = 8;
        grid.column_spacing = 8;

        grid.attach (styles_label, 0, 2, 1, 1);
        grid.attach (style_box,    1, 2, 1, 1);
        grid.attach (title,        0, 0, 2, 1);
        grid.attach (scrolled,     0, 1 ,2, 1);
        return grid;
    }

    private void make_store () {
        Gtk.ListStore list_store = new Gtk.ListStore (2, typeof (string), typeof (int));
        Gtk.TreeIter iter;

        int value = 0;
        foreach (string style in StyleLoader.STYLES) {
            list_store.append (out iter);
            list_store.set (iter, 0, style, 1, value);
        }

        // The Box:
        style_box = new Gtk.ComboBox.with_model (list_store);
        Gtk.CellRendererText renderer = new Gtk.CellRendererText ();
        style_box.pack_start (renderer, true);
        style_box.add_attribute (renderer, "text", 0);

        style_box.active = 0;
    }

    private int get_notebook_style (Notebook notebook) {
        int active = 0;

        foreach (string style in StyleLoader.STYLES) {
            if (notebook.stylesheet == style) return active;
            active++;
        }

        return 0;
    }

    private void load_data () {
        name_entry.text = notebook.name;
        style_box.active = get_notebook_style (notebook);
        style_changes.buffer.text = notebook.css;
    }

    private void connect_signals () {
        response.connect ((ID) => {
            switch (ID) {
                case 1:
                    var r = color_button.rgba.red; var g = color_button.rgba.green; var b = color_button.rgba.blue;
                    if (notebook == null) { // Create Notebook
                        if (parent_nb == null) {
                            NotebookTable.get_instance ().new_notebook (0, name_entry.text, {r,g,b}, style_changes.buffer.text, StyleLoader.STYLES[style_box.active]);
                        } else {
                           NotebookTable.get_instance ().new_notebook (parent_nb.id, name_entry.text, {r,g,b}, style_changes.buffer.text, StyleLoader.STYLES[style_box.active]);
                        }
                    } else {
                        if (style_changes.buffer.text != notebook.css || StyleLoader.STYLES[style_box.active] != notebook.stylesheet) {
                            PageTable.get_instance ().clear_cache_on (notebook.id);
                        }

                        NotebookTable.get_instance ().save_notebook (notebook.id, name_entry.text, {r,g,b}, style_changes.buffer.text, StyleLoader.STYLES[style_box.active]);
                    }

                    ENotes.Viewer.get_instance ().reload ();
                    this.close ();
                    break;
                case 2: // Cancel
                    this.close ();
                    break;
            }
        });

        name_entry.notify["text"].connect (() => {
            if (name_entry.text.strip () == "") {
                create.sensitive = false;
            } else {
                create.sensitive = true;
            }
        });
    }
}
