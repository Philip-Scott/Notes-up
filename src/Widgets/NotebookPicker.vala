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
        notebook_list = new Gtk.ListBox ();
        notebook_list.expand = true;

        add (notebook_list);
        reload ();

        notebook_list.get_style_context ().add_class ("view");
        notebook_list.get_style_context ().add_class ("source-list");

        notebook_list.row_activated.connect ((row) => {
            var element = row as NotebookElement;
            if (element != null) {
                app.state.set_database (element.file.get_path ());
            }
        });
    }

    private void reload () {
        foreach (var path in settings.recent_files) {
            var element = new NotebookElement (path);

            notebook_list.add (element);
        }

        var label = new Gtk.Label (_("More Notebooks…"));
        label.halign = Gtk.Align.START;
        label.get_style_context ().add_class ("h3");
        label.get_style_context ().add_class ("h4");

        notebook_list.add (label);
    }

    private class NotebookElement : Gtk.ListBoxRow {
        public File file { get; private set; }

        public NotebookElement (string _file) {
            file = File.new_for_path (_file);

            tooltip_text = file.get_path ();

            var label = new Gtk.Label (file.get_basename ());
            label.get_style_context ().add_class ("h4");
            label.halign = Gtk.Align.START;

            add (label);
        }
    }
}