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

public class ENotes.PageInfoEditor : Gtk.Revealer {

    private Gtk.CssProvider notebook_css_provider;
    private Gtk.Button current_notebook_button;
    private Gtk.Label current_notebook;
    private Gtk.Label created_date_label;
    private Gtk.Label updated_date_label;
    private Gtk.Grid grid;

    private ENotes.ButtonEntry page_title;

    private Gtk.ToggleButton? toggle_button;

    private ENotes.Page? _page;
    private ENotes.Page page {
        get {
            return _page;
        } set {
            if (value != null) {
                visibility = true;

                creation_date = new DateTime.from_unix_local (value.creation_date);
                modification_date = new DateTime.from_unix_local (value.modification_date);
                page_title.text = value.name;
            } else {
                visibility = false;
            }

            _page = value;
        }
    }

    private bool visibility {
        set {
            if (visible == value) return;

            visible = value;
            no_show_all = !value;
            toggle_button.visible = value;
            toggle_button.no_show_all = !value;

            toggle_button.show_all ();
            show_all ();
        }
    }

    private DateTime creation_date {
        set {
            var date = Granite.DateTime.get_relative_datetime (value);
            created_date_label.label = _("Created: %s").printf (date.to_string ());
        }
    }

    private DateTime modification_date {
        set {
            var date = Granite.DateTime.get_relative_datetime (value);
            updated_date_label.label = _("Updated: %s").printf (date.to_string ());
        }
    }

    private ENotes.Notebook? _notebook;

    private ENotes.Notebook? notebook {
        get {
            return _notebook;
        } set {
            if (value != null) {
                current_notebook.label = Markup.printf_escaped ("""%s<span color="#444" size="x-large">⌄</span>""", value.name);

                try {
                    value.rgb.alpha = 1;
                    var style = NB_STYLE.printf (value.rgb.to_string ());
                    notebook_css_provider.load_from_data (style, style.length);
                } catch (Error e) {
                    warning ("Style error: %s", e.message);
                }
            } else {
                try {
                    current_notebook.label = Markup.printf_escaped ("""%s<span color="#444" size="x-large">⌄</span>""", _("Not in Notebook"));
                    var style = NB_STYLE.printf ("#000");
                    notebook_css_provider.load_from_data (style, style.length);
                } catch (Error e) {
                    warning ("Style error: %s", e.message);
                }
            }

            _notebook = value;
        }
    }

    public PageInfoEditor () {
        visibility = false;
    }

    construct {
        grid = new Gtk.Grid ();
        grid.column_spacing = 16;
        grid.get_style_context ().add_class ("inline-toolbar");
        grid.get_style_context ().add_class ("toolbar");

        var button_grid = new Gtk.Grid ();
        button_grid.orientation = Gtk.Orientation.HORIZONTAL;

        current_notebook_button = new Gtk.Button ();
        current_notebook_button.get_style_context ().add_class ("flat");
        current_notebook_button.tooltip_text = _("Move page…");

        current_notebook = new Gtk.Label ("");
        current_notebook.use_markup = true;

        notebook_css_provider = new Gtk.CssProvider ();
        current_notebook.get_style_context ().add_provider (notebook_css_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        button_grid.add (new Gtk.Image.from_icon_name ("notebook-symbolic", Gtk.IconSize.MENU));
        button_grid.add (current_notebook);

        current_notebook_button.add (button_grid);

        var mid_separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
        mid_separator.hexpand = true;

        created_date_label = new Gtk.Label ("");
        created_date_label.halign = Gtk.Align.START;
        created_date_label.use_markup = true;
        created_date_label.get_style_context ().add_class ("h4");

        updated_date_label = new Gtk.Label ("");
        updated_date_label.halign = Gtk.Align.START;
        updated_date_label.use_markup = true;
        updated_date_label.hexpand = true;
        updated_date_label.get_style_context ().add_class ("h4");
        updated_date_label.margin_start = 8;

        var bottom_separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
        bottom_separator.hexpand = true;

        page_title = new ENotes.ButtonEntry.for_page_title ();

        var link_to_page_button = new Gtk.Button.from_icon_name ("insert-link-symbolic", Gtk.IconSize.MENU);
        link_to_page_button.halign = Gtk.Align.END;
        link_to_page_button.margin_end = 6;
        link_to_page_button.tooltip_text = _("Copy link to page to clipboard");

        var bottom_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 16);
        bottom_box.add (page_title);
        bottom_box.add (created_date_label);
        bottom_box.add (updated_date_label);
        bottom_box.add (link_to_page_button);

        var tags_box = new TagsBox ();

        grid.attach (current_notebook_button, 0, 0, 1, 1);
        grid.attach (new Gtk.Separator (Gtk.Orientation.VERTICAL), 1, 0, 1, 1);
        grid.attach (tags_box, 2, 0, 1, 1);
        grid.attach (mid_separator, 0, 1, 3, 1);
        grid.attach (bottom_box, 0, 2, 3, 1);
        grid.attach (bottom_separator, 0, 3, 3, 1);

        show_all ();

        add (grid);

        app.state.notify["opened-page"].connect (() => {
            page = app.state.opened_page;
        });

        app.state.notify["opened-page-notebook"].connect (() => {
            notebook = app.state.opened_page_notebook;
        });

        toggle_button = new Gtk.ToggleButton ();
        toggle_button.get_style_context ().add_class ("flat");
        toggle_button.get_style_context ().add_class ("circular");
        toggle_button.set_tooltip_markup (Granite.markup_accel_tooltip (app.get_accels_for_action ("win.page-info-action"), _("Toggle page information")));
        toggle_button.can_focus = false;

        var icon = new Gtk.Image.from_icon_name ("view-more-symbolic", Gtk.IconSize.MENU);
        icon.margin_start = 3;
        icon.margin_end = 3;

        toggle_button.add (icon);

        app.state.notify["show-page-info"].connect (() => {
            reveal_child = app.state.show_page_info;
            if (toggle_button.get_active () != reveal_child) {
                toggle_button.set_active (reveal_child);
            }
        });

        toggle_button.toggled.connect (() => {
            app.state.show_page_info = toggle_button.get_active ();
        });

        current_notebook_button.clicked.connect (() => {
            new NotebookListDialog.to_move_page (this.page);
        });

        link_to_page_button.clicked.connect (() => {
            var clipboard = Gtk.Clipboard.get_default (app.get_app_window ().get_display ());
            var p = this.page;

            var link_text = "<page %lld %s %s>".printf (p.id, _("Link to: "), p.name);
            clipboard.set_text (link_text, -1);
        });

        page_title.activated.connect (() => {
            app.state.opened_page.name = page_title.text;
            app.state.save_opened_page ();
        });

        app.state.update_page_title.connect (() => {
            page = app.state.opened_page;
        });

        app.state.opened_notebook_updated.connect (() => {
            notebook = app.state.opened_page_notebook;
        });


        notebook = null;
    }

    public Gtk.ToggleButton get_toggle_button () {
        return toggle_button;
    }

    private const string NB_STYLE = """* { color: %s}""";

    public class TagsBox : Gtk.ScrolledWindow {
        private ENotes.Page page;
        private Gtk.Grid grid;

        private Gee.ArrayList<Gtk.Widget> tag_widgets;
        private Gtk.EntryCompletion completion;

        private ENotes.ButtonEntry new_tag_entry;

        construct {
            hexpand = true;
            valign = Gtk.Align.CENTER;

            tag_widgets = new Gee.ArrayList<Gtk.Widget>();

            new_tag_entry = new ENotes.ButtonEntry.for_tags (_("Click to add tag…"));
            new_tag_entry.activated.connect (() => {
                TagsTable.get_instance ().create_tag (new_tag_entry.text, this.page);
                app.state.tags_changed ();
            });

            completion = new Gtk.EntryCompletion ();
            completion.set_text_column (0);

            grid = new Gtk.Grid ();
            grid.orientation = Gtk.Orientation.HORIZONTAL;
            grid.valign = Gtk.Align.CENTER;
            grid.column_spacing = 3;

            grid.add (new Gtk.Image.from_icon_name ("tag-symbolic", Gtk.IconSize.MENU));
            grid.add (new_tag_entry);

            add (grid);
            show_all ();

            app.state.notify["opened-page"].connect (() => {
                this.page = app.state.opened_page;
                update_tags (this.page);
            });

            app.state.tags_changed.connect (() => {
                update_tags (this.page);

                refresh_completion ();
            });

            refresh_completion ();
        }

        private void refresh_completion () {
            Gtk.ListStore list_store = new Gtk.ListStore (1, typeof (string));
            completion.set_model (list_store);

            Gtk.TreeIter iter;
            foreach (var tag in TagsTable.get_instance ().get_tags ()) {
                list_store.append (out iter);
                list_store.set (iter, 0, tag.name);
            }
        }

        private void update_tags (Page? page) {
            grid.remove (new_tag_entry);
            foreach (var child in tag_widgets) {
                child.destroy ();
            }

            if (page == null) return;

            var tags = TagsTable.get_instance ().get_tags_for_page (page.id);

            foreach (var tag in tags) {
                var tag_button = new Gtk.Button.with_label (tag.name);
                tag_button.get_style_context ().add_class ("flat");
                grid.add (tag_button);

                tag_widgets.add (tag_button);

                tag_button.button_release_event.connect (() => {
                    var menu = new Gtk.Menu ();
                    menu.attach_widget = tag_button;

                    var remove = new Gtk.MenuItem.with_label (_("Remove tag"));
                    menu.add (remove);
                    menu.show_all ();

                    menu.popup_at_widget (tag_button, Gdk.Gravity.SOUTH, Gdk.Gravity.NORTH);

                    remove.activate.connect (() => {
                        TagsTable.get_instance ().remove_tag_from_page (tag.id, this.page.id);
                        app.state.tags_changed ();
                    });

                    return true;
                });
            }

            new_tag_entry.hide_entry ();
            new_tag_entry.entry.text = "";
            new_tag_entry.entry.set_completion (completion);

            grid.add (new_tag_entry);
            grid.show_all ();
        }
    }
}