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
    private Gtk.MenuButton menu_button;
    private Gtk.Menu menu;
    private Gtk.MenuItem item_new;
    private Gtk.MenuItem item_preff;
    private Gtk.MenuItem item_pdf_export;
    private Gtk.MenuItem item_markdown_export;

    private ENotes.ButtonEntry search_entry;

    public Gtk.GestureSwipe gesture;

    public Headerbar (ENotes.PageInfoEditor page_info) {
        mode_button = new Granite.Widgets.ModeButton ();
        mode_button.append_text (_("View"));
        mode_button.append_text (_("Edit"));
        mode_button.valign = Gtk.Align.CENTER;

        mode_button.set_tooltip_markup (Granite.markup_accel_tooltip (app.get_accels_for_action ("win.change-mode"), _("Change mode")));

        create_menu ();

        search_entry = new ENotes.ButtonEntry.search_entry ();

        bookmark_button = new BookmarkButton ();

        set_title_from_data (null, null);
        set_show_close_button (true);

        pack_start (mode_button);
        pack_end (menu_button);
        pack_end (page_info.get_toggle_button ());
        pack_end (bookmark_button);
        pack_end (search_entry);

        this.show_all ();
        connect_signals ();
    }

    private void create_menu () {
        menu = new Gtk.Menu ();
        item_new   = new Gtk.MenuItem.with_label (_("New Notebook"));
        item_preff = new Gtk.MenuItem.with_label (_("Preferences"));

        var item_export = new Gtk.MenuItem.with_label (_("Export as…"));
        var export_submenu = new Gtk.Menu ();

        item_pdf_export = new Gtk.MenuItem.with_label (_("Export as PDF"));
        item_markdown_export = new Gtk.MenuItem.with_label (_("Export as Markdown"));

        export_submenu.add (item_pdf_export);
        export_submenu.add (item_markdown_export);

        item_export.submenu = export_submenu;

        menu.add (item_new);
        menu.add (item_export);
        menu.add (item_preff);

        menu_button = new Gtk.MenuButton ();
        menu_button.set_popup (menu);
        menu_button.set_image (new Gtk.Image.from_icon_name ("open-menu", Gtk.IconSize.LARGE_TOOLBAR));
        menu.show_all ();
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
        item_pdf_export.activate.connect (() => {
            ENotes.FileManager.export_pdf_action ();
        });

        item_markdown_export.activate.connect (() => {
            ENotes.FileManager.export_markdown_action ();
        });

        item_new.activate.connect (() => {
            var dialog = new NotebookDialog ();
            dialog.run ();
        });

        item_preff.activate.connect (() => {
            var dialog = new PreferencesDialog ();
            dialog.run ();
        });

        mode_button.mode_changed.connect ((widget) => {
            if (mode_button.selected == 0) {
                app.state.mode = ENotes.Mode.VIEW;
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
            mode_button.set_active (app.state.mode);
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
