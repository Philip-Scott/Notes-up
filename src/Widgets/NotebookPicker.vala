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

public class ENotes.NotebookPicker : Gtk.Grid {
    private Gtk.ListBox notebook_list;

    public NotebookPicker () {}

    construct {
        orientation = Gtk.Orientation.VERTICAL;

        get_style_context ().add_class ("view");
        get_style_context ().add_class ("source-list");
        get_style_context ().add_class ("notebook-list");

        notebook_list = new Gtk.ListBox ();
        notebook_list.selection_mode = Gtk.SelectionMode.BROWSE;
        notebook_list.hexpand = true;
        notebook_list.vexpand = false;

        notebook_list.get_style_context ().add_class ("view");
        notebook_list.get_style_context ().add_class ("source-list");
        notebook_list.get_style_context ().add_class ("notebook-list");

        var more_button = new Gtk.Button ();
        more_button.hexpand = true;
        more_button.get_style_context ().add_class ("flat");
        more_button.get_style_context ().add_class ("h4");

        var more_button_label = new Gtk.Label (_("More Notebooks…"));
        more_button_label.margin_start = 18;
        more_button_label.halign = Gtk.Align.START;

        more_button.add (more_button_label);

        add (notebook_list);
        add (more_button);

        reload ();

        app.state.notify["db"].connect (() => {
            // File was opened before
            if (app.state.db in settings.recent_files) {
                foreach (var element in notebook_list.get_selected_rows ()) {
                    var notebook_element = element as NotebookElement;

                    if (notebook_element != null && notebook_element.file_path == app.state.db) {
                        notebook_list.select_row (notebook_element);
                    }
                }
            } else {
                var element = new NotebookElement (app.state.db);
                notebook_list.add (element);
                notebook_list.show_all ();
                notebook_list.select_row (element);
            }
        });

        notebook_list.row_activated.connect ((row) => {
            var element = row as NotebookElement;
            if (element != null) {
                app.state.set_database (element.file_path);
            }
        });
    }

    private void reload () {
        foreach (var path in settings.recent_files) {
            var element = new NotebookElement (path);

            notebook_list.add (element);
        }
    }

    private class NotebookElement : Gtk.ListBoxRow {
        public File file { private get; construct set; }

        public string file_path {
            owned get {
                return file.get_path ();
            }
        }

        public NotebookElement (string _file) {
            Object (file: File.new_for_path (_file));
        }

        construct {
            get_style_context ().add_class ("button");
            get_style_context ().add_class ("flat");
            tooltip_text = file.get_path ();

            var label = new Gtk.Label (file.get_basename ());
            label.get_style_context ().add_class ("h3");
            label.ellipsize = Pango.EllipsizeMode.END;
            label.halign = Gtk.Align.START;

            var icon = new Gtk.Image.from_icon_name ("notebook-symbolic", Gtk.IconSize.MENU);

            var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 8);
            box.margin = 0;
            box.add (icon);
            box.add (label);

            add (box);
        }
    }
}