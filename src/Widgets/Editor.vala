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

    private ENotes.Page? _current_page = null;

    public ENotes.Page? current_page {
        get {
            return _current_page;
        } set {
            if (value == null) {
                set_sensitive (false);
                return;
            } else {
                set_sensitive (!Trash.get_instance ().is_page_trashed (value));
            }

            code_buffer.begin_not_undoable_action ();

            save_file ();

            _current_page = value;
            code_buffer.text = value.data;

            edited = false;
            code_buffer.end_not_undoable_action ();
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
        load_settings ();

        Timeout.add_full (Priority.DEFAULT, 60000, () => {
            save_file ();
            return true;
        });

        new WordWrapper(); // used to enforce initialization of static members
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
        code_view.show_line_numbers = true;

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
    }

    private Gtk.Box build_toolbar () {
        var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);

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
        if (edited) {
            edited = false;
            if (current_page != null) {
                current_page.data = this.get_text ();
                current_page.html_cache = "";
                PageTable.get_instance ().save_page (current_page);
            }
        }
    }

    public void restore () {
        if (current_page != null) {
            edited = false;
            current_page = _current_page;
        }
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

    public void load_settings () {
        set_scheme (settings.editor_scheme);
        set_font (settings.editor_font);
        show_line_numbers (settings.line_numbers);
        code_view.auto_indent = settings.auto_indent;
    }

    public void show_line_numbers (bool show) {
        code_view.set_show_line_numbers (show);

        if (show) {
            code_view.left_margin = 6;
        } else {
            code_view.left_margin = 12;
        }
    }

    public void set_font (string name) {
        var font = Pango.FontDescription.from_string (name);
        code_view.override_font (font);
    }

    public void set_scheme (string id) {
        var style_manager = Gtk.SourceStyleSchemeManager.get_default ();
        var style = style_manager.get_scheme (id);
        code_buffer.set_style_scheme (style);
    }

    private void trigger_changed () {
        edited = true;
    }
}
