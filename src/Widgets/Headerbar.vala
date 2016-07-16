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

public class ENotes.Headerbar : Gtk.HeaderBar {
    private static Headerbar? instance = null;

    public signal void mode_changed (ENotes.Mode mode);
    public signal void search_changed ();
    public signal void search_selected ();

    private ENotes.BookmarkButton bookmark_button;
    private Granite.Widgets.ModeButton mode_button;
    private Granite.Widgets.AppMenu menu_button;
    private Gtk.MenuItem item_new;
    private Gtk.MenuItem item_preff;
    private Gtk.MenuItem item_export;

    public  Gtk.Button search_button;
    public  Gtk.SearchEntry search_entry;
    public  Gtk.Revealer search_entry_revealer;
    public  Gtk.Revealer search_button_revealer;

    private bool search_visible = false;

    public static Headerbar get_instance () {
        if (instance == null) {
            instance = new Headerbar ();
        }

        return instance;
    }

    private Headerbar () {
        build_ui ();
        connect_signals ();
    }

    private void build_ui () {
        mode_button = new Granite.Widgets.ModeButton ();
        mode_button.append_text (_("View"));
        mode_button.append_text (_("Edit"));
        mode_button.valign = Gtk.Align.CENTER;

        create_menu ();

        var search_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        search_entry = new Gtk.SearchEntry();
        search_entry.editable = true;
        search_entry.visibility = true;
        search_entry.expand = true;
        search_entry.max_width_chars = 30;
        search_entry.margin_right = 12;

        search_entry_revealer = new Gtk.Revealer();
        search_button_revealer = new Gtk.Revealer();
        search_entry_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_LEFT;
        search_button_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_LEFT;

        search_button = new Gtk.Button.from_icon_name ("edit-find-symbolic", Gtk.IconSize.LARGE_TOOLBAR);
        search_button.has_tooltip = true;
        search_button.tooltip_text = _("Search your current notebook");
        search_button.clicked.connect(show_search);

        search_button_revealer.add(search_button);
        search_entry_revealer.add(search_entry);
        search_entry_revealer.reveal_child = false;
        search_button_revealer.reveal_child = true;

        bookmark_button = BookmarkButton.get_instance ();

        set_title (null);
        set_show_close_button (true);

        pack_start (mode_button);
        pack_end (menu_button);
        pack_end (bookmark_button);
        search_box.add (search_button_revealer);
        search_box.add (search_entry_revealer);
        pack_end (search_box);

        this.show_all ();
    }

    private void create_menu () {
        var menu = new Gtk.Menu ();
        item_new   = new Gtk.MenuItem.with_label (_("New Notebook"));
        item_preff = new Gtk.MenuItem.with_label (_("Preferences"));
        item_export = new Gtk.MenuItem.with_label (_("Export to PDF"));
        menu.add (item_new);
        menu.add (item_export);
        menu.add (item_preff);

        var separator = new Gtk.SeparatorMenuItem ();
        menu.add (separator);

        var contracts = Granite.Services.ContractorProxy.get_contracts_by_mime ("application/pdf");
        foreach (var contract in contracts) {
            var contract_item = new Gtk.MenuItem.with_label (contract.get_display_name ());
            menu.add (contract_item);

            contract_item.activate.connect (() => {
                if (ViewEditStack.get_instance ().current_page != null) {
                    string name = ViewEditStack.get_instance ().current_page.name;
                    var file = FileManager.export_pdf_action ("/tmp/%s.pdf".printf(name));

                    Idle.add (() => {
                        contract.execute_with_file (file);
                        return false;
                    });
                }
            });
        }

        menu_button = new Granite.Widgets.AppMenu (menu);
    }

    public void set_mode (ENotes.Mode mode) {
        mode_button.set_active (mode);
    }

    public new void set_title (string? title) {
        if (title != null) {
            this.title = title + " - Notes-up";
        } else {
            this.title = "Notes-up";
        }
    }

    private void connect_signals () {
        item_export.activate.connect (() => {
            ENotes.FileManager.export_pdf_action ();
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
                mode_changed (ENotes.Mode.VIEW);
            } else {
                mode_changed (ENotes.Mode.EDIT);
            }
        });

        search_entry.activate.connect (() => {
            search_selected ();
        });

        search_entry.icon_release.connect ((p0, p1) => {
            if (!has_focus) hide_search ();
        });

        search_entry.search_changed.connect(() => {
            search_changed ();
        });

        search_entry.focus_out_event.connect (() => {
            if (search_entry.get_text () == "") {
                hide_search ();
            }

            return false;
        });
    }

    public void show_search() {
        search_button_revealer.reveal_child = false;
        search_entry_revealer.reveal_child = true;
        show_all();
        search_visible = true;
        search_entry.can_focus = true;
        search_entry.grab_focus();
    }

    public void hide_search() {
        search_entry_revealer.reveal_child = false;
        search_button_revealer.reveal_child = true;
        show_all();
        search_visible = false;
    }
}
