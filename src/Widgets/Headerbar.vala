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

public class ENotes.ButtonEntry : Gtk.Grid {
    public signal void changed (string text);
    public signal void activated ();

    public Gtk.Entry entry { get; construct; }

    private Gtk.Revealer entry_revealer;
    private Gtk.Revealer button_revealer;

    private Gtk.Button button;
    private bool hide_if_contains_text = false;

    private bool always_shown_when_revealed = false;
    private bool setting = false;
    private Gtk.Label label;

    public string text {
        get {
            return entry.text;
        } set {
            setting = true;
            label.label = value;
            entry.text = value;
            setting = false;
        }
    }

    public class ButtonEntry.search_entry () {
        Object (entry: new Gtk.SearchEntry ());
        orientation = Gtk.Orientation.HORIZONTAL;
        halign = Gtk.Align.END;

        (entry as Gtk.SearchEntry).search_changed.connect(() => {
            changed (entry.get_text ());
        });

        button = new Gtk.Button.from_icon_name ("edit-find-symbolic", Gtk.IconSize.LARGE_TOOLBAR);
        button.set_tooltip_markup (Granite.markup_accel_tooltip (app.get_accels_for_action ("win.find-action"), _("Search your current notebook")));

        button_revealer.add (button);
        button.clicked.connect (show_entry);

        add (entry_revealer);
        add (button_revealer);
        entry_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_RIGHT;
        button_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_RIGHT;

        entry.icon_release.connect ((p0, p1) => {
            if (!has_focus) hide_entry ();
        });
    }

    public class ButtonEntry.for_tags (string tag_text) {
        Object (entry: new Gtk.Entry ());
        orientation = Gtk.Orientation.VERTICAL;
        always_shown_when_revealed = true;

        halign = Gtk.Align.START;
        valign = Gtk.Align.CENTER;
        vexpand = false;

        button = new Gtk.Button ();
        button.set_tooltip_markup (_("Add Tag"));
        button.clicked.connect (show_entry);
        button.get_style_context ().add_class ("flat");

        label = new Gtk.Label (tag_text);

        entry.halign = Gtk.Align.FILL;
        entry.show_emoji_icon = true;
        entry.max_width_chars = 3;
        entry.width_chars = 1;
        entry.margin = 0;

        button.add (label);
        button_revealer.add (button);
        add (entry_revealer);
        add (button_revealer);

        entry_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN;
        button_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN;
    }

    public class ButtonEntry.for_page_title () {
        Object (entry: new Gtk.Entry ());
        orientation = Gtk.Orientation.VERTICAL;
        hide_if_contains_text = true;
        halign = Gtk.Align.START;
        vexpand = false;

        button = new Gtk.Button ();
        button.set_tooltip_markup (_("Edit Page Title"));

        label = new Gtk.Label ("");
        label.ellipsize = Pango.EllipsizeMode.END;

        var button_grid = new Gtk.Grid ();
        button_grid.orientation = Gtk.Orientation.HORIZONTAL;
        button_grid.add (new Gtk.Image.from_icon_name ("folder-documents-symbolic", Gtk.IconSize.MENU));
        button_grid.add (label);
        button.clicked.connect (show_entry);
        button.get_style_context ().add_class ("flat");

        entry.halign = Gtk.Align.FILL;
        entry.max_width_chars = 3;
        entry.width_chars = 1;
        entry.margin = 2;

        button.add (button_grid);
        button_revealer.add (button);
        add (entry_revealer);
        add (button_revealer);

        entry_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN;
        button_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN;
    }

    construct {
        valign = Gtk.Align.CENTER;

        entry.editable = true;
        entry.visibility = true;
        entry.expand = false;
        entry.max_width_chars = 30;
        entry.margin_end = 12;

        entry_revealer = new Gtk.Revealer ();
        entry_revealer.valign = Gtk.Align.CENTER;
        entry_revealer.add (entry);
        entry_revealer.reveal_child = false;

        button_revealer = new Gtk.Revealer ();
        button_revealer.reveal_child = true;

        entry.activate.connect (() => {
            activated ();
        });

        entry.focus_out_event.connect (() => {
            if (!always_shown_when_revealed && (this.hide_if_contains_text || entry.get_text () == "")) {
                hide_entry ();
            }

            return false;
        });
    }

    public void show_entry () {
        button_revealer.reveal_child = false;
        entry_revealer.reveal_child = true;

        show_all ();

        entry.can_focus = true;
        entry.grab_focus ();
    }

    public void hide_entry () {
        entry_revealer.reveal_child = false;
        button_revealer.reveal_child = true;

        entry.can_focus = false;

        show_all ();
    }
}

public class ENotes.Headerbar : Gtk.HeaderBar {
    public ENotes.BookmarkButton bookmark_button;

    private Granite.Widgets.ModeButton mode_button;
    private Gtk.MenuButton app_menu;
    private Gtk.MenuButton panel_picker_menu;

    private ENotes.ButtonEntry search_entry;

    public Gtk.GestureSwipe gesture;

    public Headerbar (ENotes.PageInfoEditor page_info) {
        mode_button = new Granite.Widgets.ModeButton ();
        mode_button.append_text (_("View"));
        mode_button.append_icon ("view-dual-symbolic", Gtk.IconSize.MENU);
        mode_button.append_text (_("Edit"));

        mode_button.valign = Gtk.Align.CENTER;

        mode_button.set_tooltip_markup (Granite.markup_accel_tooltip (app.get_accels_for_action ("win.change-mode"), _("Change mode")));

        create_menu ();
        make_panel_picker_menu ();

        search_entry = new ENotes.ButtonEntry.search_entry ();

        subtitle = ENotes.FileDataTable.instance.get_value (FileDataType.FILE_NAME);
        bookmark_button = new BookmarkButton ();

        set_title_from_data (null, null);
        set_show_close_button (true);

        pack_start (panel_picker_menu);
        pack_start (mode_button);
        pack_end (app_menu);
        pack_end (page_info.get_toggle_button ());
        pack_end (bookmark_button);
        pack_end (search_entry);

        this.show_all ();
        connect_signals ();
    }

    private void make_panel_picker_menu () {
        var panes_two_item = model_button_entry (_("Show Sections and Pages"), "panes-two-symbolic");
        var panes_one_item = model_button_entry (_("Show Only Pages"), "panes-one-symbolic");
        var show_none_item = model_button_entry (_("Hide All"), "panes-none-symbolic");

        var menu_grid = new Gtk.Grid ();
        menu_grid.margin_top = 3;
        menu_grid.margin_bottom = 3;
        menu_grid.orientation = Gtk.Orientation.VERTICAL;

        if (ENotes.FeatureFlags.SHOW_NOTEBOOK_PANE) {
            var show_all_item = model_button_entry (_("Show All"), "panes-all-symbolic");
            menu_grid.add (show_all_item);

            show_all_item.clicked.connect (() => {
                app.state.panes_visible = 3;
            });
        }

        menu_grid.add (panes_two_item);
        menu_grid.add (panes_one_item);
        menu_grid.add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
        menu_grid.add (show_none_item);

        var menu = new Gtk.Popover (null);
        menu.add (menu_grid);

        menu_grid.show_all ();
        menu_grid.expand = true;

        panel_picker_menu = new Gtk.MenuButton ();
        panel_picker_menu.image = new Gtk.Image.from_icon_name ("panes-all-symbolic", Gtk.IconSize.MENU);
        panel_picker_menu.popover = menu;
        panel_picker_menu.margin_end = 3;

        panel_picker_menu.set_tooltip_markup (
            Granite.markup_accel_tooltip (
                {"<Ctrl>P", "<Ctrl><Shift>P"},
                _("Panel Options")
            )
        );

        panes_two_item.clicked.connect (() => {
            app.state.panes_visible = 2;
        });

        panes_one_item.clicked.connect (() => {
            app.state.panes_visible = 1;
        });

        show_none_item.clicked.connect (() => {
            app.state.panes_visible = 0;
        });

        app.state.notify["panes-visible"].connect (() => {
            switch (app.state.panes_visible) {
                case 0:
                    panel_picker_menu.image = new Gtk.Image.from_icon_name ("panes-none-symbolic", Gtk.IconSize.MENU);
                    break;
                case 1:
                    panel_picker_menu.image = new Gtk.Image.from_icon_name ("panes-one-symbolic", Gtk.IconSize.MENU);
                    break;
                case 2:
                    panel_picker_menu.image = new Gtk.Image.from_icon_name ("panes-two-symbolic", Gtk.IconSize.MENU);
                    break;
                case 3:
                    panel_picker_menu.image = new Gtk.Image.from_icon_name ("panes-all-symbolic", Gtk.IconSize.MENU);
                    break;
            }
        });
    }

    private Gtk.ModelButton model_button_entry (string text, string? icon_name) {
        var button = new Gtk.ModelButton ();

        if (icon_name != null) {
            var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
            var icon = new Gtk.Image.from_icon_name (icon_name, Gtk.IconSize.MENU);

            var label = new Gtk.Label (text);

            box.add (icon);
            box.add (label);

            button.get_child ().destroy ();
            button.add (box);
            button.show_all ();
        } else {
            button.text = text;
        }

        return button;
    }

    private void create_menu () {
        var color_button_white = new Gtk.RadioButton (null);
        color_button_white.halign = Gtk.Align.CENTER;
        color_button_white.tooltip_text = _("High Contrast");

        var color_button_white_context = color_button_white.get_style_context ();
        color_button_white_context.add_class ("color-button");
        color_button_white_context.add_class ("color-white");

        var color_button_light = new Gtk.RadioButton.from_widget (color_button_white);
        color_button_light.halign = Gtk.Align.CENTER;
        color_button_light.tooltip_text = _("Solarized Light");

        var color_button_light_context = color_button_light.get_style_context ();
        color_button_light_context.add_class ("color-button");
        color_button_light_context.add_class ("color-light");

        var color_button_dark = new Gtk.RadioButton.from_widget (color_button_white);
        color_button_dark.halign = Gtk.Align.CENTER;
        color_button_dark.tooltip_text = _("Solarized Dark");

        var color_button_dark_context = color_button_dark.get_style_context ();
        color_button_dark_context.add_class ("color-button");
        color_button_dark_context.add_class ("color-dark");

        var menu_separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
        menu_separator.margin_top = 12;

        var menu_separator_2 = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);

        var notebook_new_menu_item = model_button_entry (_("New Section"), null);
        var preferences_menu_item = model_button_entry (_("Preferences"), null);
        var export_pdf_menu_item = model_button_entry (_("Export as PDF"), null);
        var export_markdown_menu_item = model_button_entry (_("Export as Markdown"), null);

        var menu_grid = new Gtk.Grid ();
        menu_grid.margin_top = 12;
        menu_grid.margin_bottom = 3;
        menu_grid.orientation = Gtk.Orientation.VERTICAL;
        menu_grid.attach (color_button_white, 0, 1, 1, 1);
        menu_grid.attach (color_button_light, 1, 1, 1, 1);
        menu_grid.attach (color_button_dark, 2, 1, 1, 1);
        menu_grid.attach (menu_separator, 0, 2, 3, 1);
        menu_grid.attach (notebook_new_menu_item, 0, 3, 3, 1);
        menu_grid.attach (preferences_menu_item, 0, 4, 3, 1);
        menu_grid.attach (menu_separator_2, 0, 5, 3, 1);
        menu_grid.attach (export_pdf_menu_item, 0, 6, 3, 1);
        menu_grid.attach (export_markdown_menu_item, 0, 7, 3, 1);
        menu_grid.show_all ();
        menu_grid.expand = true;

        var menu = new Gtk.Popover (null);
        menu.add (menu_grid);

        app_menu = new Gtk.MenuButton ();
        app_menu.image = new Gtk.Image.from_icon_name ("open-menu", Gtk.IconSize.LARGE_TOOLBAR);
        app_menu.tooltip_text = _("Menu");
        app_menu.popover = menu;

        app.state.notify["style-scheme"].connect (() => {
            switch (app.state.style_scheme) {
                case "high-contrast":
                    color_button_white.active = true;
                    break;
                case "solarized-light":
                    color_button_light.active = true;
                    break;
                case "solarized-dark":
                    color_button_dark.active = true;
                    break;
             }
        });

        app.state.file_data_changed.connect ((type, value) => {
            if (type == FileDataType.FILE_NAME) {
                subtitle = value;
            }
        });

        color_button_dark.clicked.connect (() => {
            app.state.set_style ("solarized-dark");

        });

        color_button_light.clicked.connect (() => {
            app.state.set_style ("solarized-light");
        });

        color_button_white.clicked.connect (() => {
            app.state.set_style ("high-contrast");
        });

        export_pdf_menu_item.clicked.connect (() => {
            ENotes.FileManager.export_pdf_action ();
        });

        export_markdown_menu_item.clicked.connect (() => {
            ENotes.FileManager.export_markdown_action ();
        });

        notebook_new_menu_item.clicked.connect (() => {
            var dialog = new NotebookDialog ();
            dialog.run ();
        });

        preferences_menu_item.clicked.connect (() => {
            var dialog = new PreferencesDialog ();
            dialog.run ();
        });
    }

    public void set_mode (ENotes.Mode mode) {
        app.state.mode = mode;
        mode_button.set_active (mode);
    }

    private void set_title_from_data (string? page_title, string? notebook_title) {
        if (page_title != null && notebook_title != null) {
            this.title = page_title + " - " + notebook_title;
        } else if (page_title != null) {
            this.title = page_title;
        } else if (notebook_title != null) {
            this.title = notebook_title;
        } else {
            this.title = "";
        }

        this.title = this.title.replace ("&amp;", "&");
    }

    private void connect_signals () {
        mode_button.mode_changed.connect ((widget) => {
            if (mode_button.selected == 0) {
                app.state.mode = ENotes.Mode.VIEW;
            } else if (mode_button.selected == 1){
                app.state.mode = ENotes.Mode.BOTH;
            } else {
                app.state.mode = ENotes.Mode.EDIT;
            }
        });

        search_entry.activated.connect (() => {
            app.state.search_selected ();
        });

        search_entry.changed.connect ((text) => {
            app.state.search_field = text;
        });

        app.state.notify["mode"].connect (() => {
            switch (app.state.mode) {
                case ENotes.Mode.VIEW: mode_button.set_active (0); return;
                case ENotes.Mode.BOTH: mode_button.set_active (1); return;
                case ENotes.Mode.EDIT: mode_button.set_active (2); return;
            }
        });

        app.state.update_page_title.connect (() => {
            var notebook = app.state.opened_page_notebook;
            var page = app.state.opened_page;

            set_title_from_data (page != null ? page.name : null, notebook != null ? notebook.name : null);
        });

        app.state.page_deleted.connect (() => {
            set_title_from_data (null, null);
        });
    }

    public void show_search () {
        search_entry.show_entry ();
    }
}
