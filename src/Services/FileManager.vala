/*
* Copyright (c) 2015-2016 Felipe Escoto (https://github.com/Philip-Scott/Notes-up)
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

public class ENotes.FileManager : Object {

    public static File? export_pdf_action (string? file_path = null) {
        ENotes.ViewEditStack.get_instance ().viewer.load_page (app.state.opened_page, true);

        File file;
        if (file_path == null) {
            file = get_file_from_user ("pdf", Gtk.FileChooserAction.SAVE);
        } else {
            file = File.new_for_path (file_path);
        }

        if (file == null) {
          return null;
        }

        if (!file.get_basename ().down ().has_suffix (".pdf")) {
            file = File.new_for_path (file.get_path () + ".pdf");
        }

        try { // TODO: we have to write an empty file so we can get file path
            write_file (file, "");
        } catch (Error e) {
            warning ("Could not write initial PDF file: %s", e.message);
            return null;
        }

        var op = new WebKit.PrintOperation (ENotes.ViewEditStack.get_instance ().viewer);
        var settings = new Gtk.PrintSettings ();
        settings.set_printer (_("Print to File"));

        settings[Gtk.PRINT_SETTINGS_OUTPUT_URI] = file.get_uri ();
        op.set_print_settings (settings);

        op.print ();

        return file;
    }

    public static File? export_markdown_action (string? file_path = null) {
        File file;
        if (file_path == null) {
            file = get_file_from_user ("md", Gtk.FileChooserAction.SAVE);
        } else {
            file = File.new_for_path (file_path);
        }

        if (file == null) {
          return null;
        }

        if (!file.get_basename ().down ().has_suffix (".md")) {
            file = File.new_for_path (file.get_path () + ".md");
        }

        var editor = ENotes.ViewEditStack.get_instance ().editor;
        editor.save_file ();

        try {
            FileUtils.set_data (file.get_path (), (uint8[]) app.state.opened_page.data.to_utf8 ());
        } catch (Error e) {
            warning ("Failed to export file %s", e.message);
        }

        return file;
    }

    public static void write_file (File file, string contents, bool overrite = false) throws Error {
        if (file.query_exists () && overrite) {
            file.delete ();
        }

        create_file_if_not_exists (file);

        file.open_readwrite_async.begin (Priority.DEFAULT, null, (obj, res) => {
            try {
                var iostream = file.open_readwrite_async.end (res);
                var ostream = iostream.output_stream;
                ostream.write_all (contents.data, null);
            } catch (Error e) {
                warning ("Could not write file \"%s\": %s", file.get_basename (), e.message);
            }
        });
    }

    public static void create_file_if_not_exists (File file) throws Error{
        if (!file.query_exists ()) {
            try {
                file.create (FileCreateFlags.REPLACE_DESTINATION);
            } catch (Error e) {
                throw new Error (Quark.from_string (""), -1, "Could not write file: %s", e.message);
            }
        }
    }

    public static File? get_file_from_user (string filetype, Gtk.FileChooserAction? chooser_action) {
        File? result = null;

        string title = "";
        string accept_button_label = "";
        List<Gtk.FileFilter> filters = new List<Gtk.FileFilter> ();

        switch (filetype) {
            case "pdf":
                title =  _("Save as PDF");
                var filter = new Gtk.FileFilter ();
                filter.set_filter_name (_("PDF File"));

                filter.add_mime_type ("application/pdf");
                filter.add_pattern ("*.pdf");

                filters.append (filter);
                break;
            case "md":
                title =  _("Save as Markdown");
                var filter = new Gtk.FileFilter ();
                filter.set_filter_name (_("Markdown File"));

                filter.add_mime_type ("text/markdown");
                filter.add_pattern ("*.md");

                filters.append (filter);
                break;
            case "image":
                title =  _("Open Image");

                var filter = new Gtk.FileFilter ();
                filter.set_filter_name (_("Images"));
                filter.add_mime_type ("image/*");

                filters.append (filter);
                break;
            case "ndb":
                title =  _("Create or Open a Notes-Up File");

                var filter = new Gtk.FileFilter ();
                filter.set_filter_name (_("Notes-Up Notebook"));
                filter.add_mime_type ("application/x-notesup");
                filter.add_pattern ("*.ndb");

                filters.append (filter);
                break;
            default:
                assert_not_reached ();
        }

        if (chooser_action == Gtk.FileChooserAction.SAVE) {
            accept_button_label = _("Save");
        } else if (chooser_action == Gtk.FileChooserAction.OPEN) {
            accept_button_label = _("Open");
        } else {
            accept_button_label = _("Open or Create");
            chooser_action = Gtk.FileChooserAction.SAVE;
        }

        var all_filter = new Gtk.FileFilter ();
        all_filter.set_filter_name (_("All Files"));
        all_filter.add_pattern ("*");

        filters.append (all_filter);

        var dialog = new Gtk.FileChooserDialog (
            title,
            app.get_active_window (),
            chooser_action,
            _("Cancel"), Gtk.ResponseType.CANCEL,
            accept_button_label, Gtk.ResponseType.ACCEPT);


        filters.@foreach ((filter) => {
            dialog.add_filter (filter);
        });

        if (dialog.run () == Gtk.ResponseType.ACCEPT) {
            result = dialog.get_file ();
        }

        dialog.close ();

        return result;
    }
}
