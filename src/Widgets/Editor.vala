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

public class ENotes.Editor : Gtk.Box {
    private Gtk.SourceView code_view;
    private Gtk.SourceBuffer code_buffer;
    private Gtk.Box editor_and_help;
    private ENotes.HelpBox? help = null;
    private GtkSpell.Checker spell = null;

    private bool edited = false;

    private Gtk.SourceSearchContext search_context;
    private Gtk.SourceSearchSettings search_settings;

    private ENotes.Page? current_page {
         set {
            if (text_change_timeout != 0) {
                GLib.Source.remove (text_change_timeout);
                text_change_timeout = 0;
            }

            if (value == null) {
                set_sensitive (false);
                code_buffer.changed.disconnect (trigger_changed);
                code_buffer.begin_not_undoable_action ();
                code_buffer.text = "";
                edited = false;
                code_buffer.end_not_undoable_action ();
                code_buffer.changed.connect (trigger_changed);
                return;
            } else {
                set_sensitive (!Trash.get_instance ().is_page_trashed (value));
            }

            code_buffer.changed.disconnect (trigger_changed);
            code_buffer.begin_not_undoable_action ();
            code_buffer.text = value.data;
            edited = false;
            code_buffer.end_not_undoable_action ();
            code_buffer.changed.connect (trigger_changed);
        }
    }

    public bool spellcheck {
        set {
            if (value) {
                try {
                    var last_language = Services.Settings.get_instance ().spellcheck_language;
                    var language_list = GtkSpell.Checker.get_language_list ();

                    bool language_set = false;
                    foreach (var element in language_list) {
                        if (last_language == element) {
                            spell.set_language (last_language);
                            language_set = true;
                            break;
                        }
                    }

                    if (language_list.length () == 0) {
                        spell.set_language (null);
                    } else if (!language_set) {
                        last_language = language_list.first ().data;
                        spell.set_language (last_language);
                    }
                    spell.attach (code_view);
                } catch (Error e) {
                    warning (e.message);
                }
            } else {
                spell.detach ();
            }
        }
    }

    public ENotes.ToolbarButton bold_button;
    public ENotes.ToolbarButton italics_button;
    public ENotes.ToolbarButton strike_button;

    public Editor () {
        build_ui ();
        reset ();

        Timeout.add_full (Priority.DEFAULT, 60000, () => {
            save_file ();
            return true;
        });

        new WordWrapper(); // used to enforce initialization of static members

        search_settings = new Gtk.SourceSearchSettings ();
        search_settings.set_case_sensitive (false);
        search_settings.set_regex_enabled (false);

        search_context = new Gtk.SourceSearchContext (code_buffer, search_settings);
    }

    private void build_ui () {
        var manager = Gtk.SourceLanguageManager.get_default ();
        var language = manager.guess_language (null, "text/x-markdown");
        code_buffer = new Gtk.SourceBuffer.with_language (language);
        code_buffer.set_max_undo_levels (100);

        code_view = new Gtk.SourceView.with_buffer (code_buffer);

        set_size_request (250,50);
        orientation = Gtk.Orientation.VERTICAL;
        expand = true;

        code_buffer.changed.connect (trigger_changed);

        code_view.pixels_below_lines = 6;
        code_view.wrap_mode = Gtk.WrapMode.WORD;
        show_line_numbers (false);

        var scroll_box = new Gtk.ScrolledWindow (null, null);
        scroll_box.add (code_view);

        editor_and_help = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        editor_and_help.add (scroll_box);

        spell = new GtkSpell.Checker ();
        spell.decode_language_codes = true;

        spellcheck = Services.Settings.get_instance ().spellcheck;

        spell.language_changed.connect (() => {
            Services.Settings.get_instance ().spellcheck_language = spell.get_language ();
        });

        add (build_toolbar ());
        add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
        add (editor_and_help);
        set_sensitive (false);
        scroll_box.expand = true;

        show_all ();

        app.state.notify["opened-page"].connect (() => {
            current_page = app.state.opened_page;
        });

        app.state.request_saving_page_info.connect (() => {
            save_file ();
        });

        app.state.notify["editor-font"].connect (() => {
            set_font (app.state.editor_font);
        });

        app.state.notify["editor-scheme"].connect (() => {
            set_scheme (app.state.editor_scheme);
        });

        app.state.notify["editor-show-line-numbers"].connect (() => {
            show_line_numbers (app.state.editor_show_line_numbers);
        });

        app.state.notify["editor-auto-indent"].connect (() => {
            code_view.auto_indent = app.state.editor_auto_indent;
        });

        app.state.notify["search-field"].connect (() => {
            search_settings.set_search_text (app.state.search_field);
        });
    }

    private Gtk.Box build_toolbar () {
        var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        box.get_style_context ().add_class ("inline-toolbar");

        bold_button = new ENotes.ToolbarButton (
            "format-text-bold-symbolic",
            "**", "**",
            Granite.markup_accel_tooltip (app.get_accels_for_action ("win.bold-action"), _("Add bold to text")),
            code_buffer
        );

        italics_button = new ENotes.ToolbarButton (
            "format-text-italic-symbolic",
            "_", "_",
            Granite.markup_accel_tooltip (app.get_accels_for_action ("win.italics-action"), _("Add italic to text")),
            code_buffer
        );

        strike_button = new ENotes.ToolbarButton (
            "format-text-strikethrough-symbolic",
            "~~", "~~",
            Granite.markup_accel_tooltip (app.get_accels_for_action ("win.strike-action"), _("Strikethrough text")),
            code_buffer
        );

        var quote_button = new ENotes.ToolbarButton ("format-indent-less-rtl", "> ", "", _("Insert a quote"), code_buffer);
        var code_button = new ENotes.ToolbarButton ("system-run", "`", "`", _("Insert code"), code_buffer);
        var link_button = new ENotes.ToolbarButton ("insert-link", "[Link Text](", ")", _("Insert a link"), code_buffer);

        var bulleted_button = new ENotes.ToolbarButton ("zoom-out","\n- ", "", _("Add a bulleted list"), code_buffer);
        var numbered_button = new ENotes.ToolbarButton ("zoom-original","\n1. ", "", _("Add a Numbered list"), code_buffer);

        var webimage_button = new ENotes.ToolbarButton.is_image_button ("insert-image","![](", ")", _("Insert an image"), code_buffer);

        var separator1 = new Gtk.Separator (Gtk.Orientation.VERTICAL);
        var separator2 = new Gtk.Separator (Gtk.Orientation.VERTICAL);
        var separator3 = new Gtk.Separator (Gtk.Orientation.VERTICAL);

        separator1.margin_start = 4;
        separator2.margin_start = 4;
        separator3.margin_start = 4;

        separator1.margin_end = 4;
        separator2.margin_end = 4;
        separator3.margin_end = 4;

        box.add (bold_button);
        box.add (italics_button);
        box.add (strike_button);
        box.add (separator1);
        box.add (quote_button);
        box.add (code_button);

        box.add (bulleted_button);
        box.add (numbered_button);
        box.add (separator2);
        box.add (link_button);
        box.add (webimage_button);
        box.add (separator3);

        // Load Plugin buttons
        foreach (var plugin in PluginManager.get_instance ().get_plugs ()) {
            Gtk.Widget? widget = plugin.editor_button ();
            if (widget != null) {
                box.add (new ENotes.ToolbarButton.from_plugin (plugin, widget, code_buffer));
            }
        }

        var help_button = new Gtk.ToggleButton ();
        var help_icon = new Gtk.Image.from_icon_name ("dialog-question-symbolic", Gtk.IconSize.MENU);

        help_button.set_tooltip_text (_("Formatting"));
        help_button.get_style_context ().add_class ("flat");
        help_button.can_focus = false;
        help_button.hexpand = true;
        help_button.halign = Gtk.Align.END;

        help_button.toggled.connect (() => {
            if (help == null) {
                help = new ENotes.HelpBox ();
                help.insert_requested.connect ((text) => {
                    code_buffer.insert_at_cursor (text, -1);
                });

                editor_and_help.add (help);
            }

            help.set_reveal_child (help_button.get_active ());
        });

        help_button.add (help_icon);
        box.add (help_button);

        return box;
    }

    public void save_file () {
        if (app.state.opened_page == null) return;

        if (edited) {
            app.state.opened_page.data = this.get_text ();
            app.state.opened_page.html_cache = "";
        }

        if (edited || app.state.opened_page.cache_changed) {
            app.state.save_opened_page ();
        }

        edited = false;
    }

    public void reset (bool disable_save = false) {
        if (disable_save) {
            edited = false;
        }

        code_buffer.text = "";
    }

    public string get_text () {
        return code_view.buffer.text;
    }

    public void give_focus () {
        code_view.grab_focus ();
    }

    private void show_line_numbers (bool show) {
        code_view.set_show_line_numbers (show);

        if (show) {
            code_view.left_margin = 6;
        } else {
            code_view.left_margin = 12;
        }
    }

    private void set_font (string name) {
        var font = Pango.FontDescription.from_string (name);
        code_view.override_font (font);
    }

    private void set_scheme (string id) {
        var style_manager = Gtk.SourceStyleSchemeManager.get_default ();
        var style = style_manager.get_scheme (id);
        code_buffer.set_style_scheme (style);
    }

    uint text_change_timeout = 0;
    private void trigger_changed () {
        if (app.state.opened_page == null) return;

        if (text_change_timeout != 0) {
            GLib.Source.remove (text_change_timeout);
            text_change_timeout = 0;
        }

        edited = true;

        text_change_timeout = Timeout.add_full (Priority.DEFAULT, 1000, () => {
            text_change_timeout = 0;

            app.state.opened_page.data = this.get_text ();
            app.state.page_text_updated ();

            return Source.REMOVE;
        });
    }
}
