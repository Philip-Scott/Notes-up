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
    private static Editor? instance = null;

    private Gtk.SourceView code_view;
    private Gtk.SourceBuffer code_buffer;
    private Gtk.Box editor_and_help;
    private ENotes.PluginSidebar? plugin_sidebar = null;
    private GtkSpell.Checker spell = null;

    private bool edited = false;

    private ENotes.Page? _current_page = null;

    public ENotes.Page current_page {
        get {
            return _current_page;
        } set {
            code_buffer.begin_not_undoable_action ();

            save_file ();

            _current_page = value;
            code_buffer.text = value.data;

            edited = false;
            code_buffer.end_not_undoable_action ();

            set_sensitive (true);
        }
    }

    public bool spellcheck {
        set {
            if (value) {
                try {
                    var last_language = Services.Settings.get_instance ().spellcheck_language;
                    bool language_set = false;
                    var language_list = GtkSpell.Checker.get_language_list ();
                    foreach (var element in language_list) {
                        if (last_language == element) {
                            language_set = true;
                            spell.set_language (last_language);
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

    public static Editor get_instance () {
        if (instance == null) {
            instance = new Editor ();
        }

        return instance;
    }

    private Editor () {
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
        expand = true;

        code_buffer.changed.connect (trigger_changed);

        code_view.pixels_below_lines = 6;
        code_view.wrap_mode = Gtk.WrapMode.WORD;
        code_view.show_line_numbers = true;

        var scroll_box = new Gtk.ScrolledWindow (null, null);
        scroll_box.add (code_view);

        editor_and_help = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        editor_and_help.add (scroll_box);

        plugin_sidebar = ENotes.PluginSidebar.get_instance ();
        editor_and_help.add (plugin_sidebar);

        spell = new GtkSpell.Checker ();
        spellcheck = Services.Settings.get_instance ().spellcheck;

        code_view.populate_popup.connect ((menu) => {
            menu.selection_done.connect (() => {
                var selected = get_selected (menu);

                if (selected != null) {
                    try {
                        spell.set_language (selected.label);
                        Services.Settings.get_instance ().spellcheck_language = selected.label;
                    } catch (Error e) {}
                }
            });

        });

        this.set_orientation (Gtk.Orientation.VERTICAL);
        this.add (build_toolbar ());
        this.add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
        this.add (editor_and_help);
        this.set_sensitive (false);
        scroll_box.expand = true;
        this.show_all ();
    }

    private Gtk.MenuItem? get_selected (Gtk.Menu? menu) {
        if (menu == null) return null;
        var active = menu.get_active () as Gtk.MenuItem;

        if (active == null) return null;

        var sub_menu = active.get_submenu () as Gtk.Menu;

        if (sub_menu != null) {
            return sub_menu.get_active () as Gtk.MenuItem;
        }

        return null;
    }

    private Gtk.Box build_toolbar () {
        var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);

        bold_button = new ENotes.ToolbarButton ("format-text-bold-symbolic", "**", "**", _("Add bold to text") + Key.BOLD.to_string (), code_buffer);
        italics_button = new ENotes.ToolbarButton ("format-text-italic-symbolic", "_", "_", _("Add italic to text") + Key.ITALICS.to_string (), code_buffer);
        strike_button = new ENotes.ToolbarButton ("format-text-strikethrough-symbolic", "~~", "~~", _("Strikethrough text") + Key.STRIKE.to_string (), code_buffer);

        var quote_button = new ENotes.ToolbarButton ("format-indent-less-rtl", "> ", "", _("Insert a quote"), code_buffer);
        var code_button = new ENotes.ToolbarButton ("system-run", "`", "`", _("Insert code"), code_buffer);
        var link_button = new ENotes.ToolbarButton ("insert-link", "[Link Text](", ")", _("Insert a link"), code_buffer);

        var bulleted_button = new ENotes.ToolbarButton ("zoom-out","\n- ", "", _("Add a bulleted list"), code_buffer);
        var numbered_button = new ENotes.ToolbarButton ("zoom-original","\n1. ", "", _("Add a Numbered list"), code_buffer);

        var webimage_button = new ENotes.ToolbarButton.is_image_button ("insert-image","![](", ")", _("Insert an image"), code_buffer);

        var separator1 = new Gtk.Separator (Gtk.Orientation.VERTICAL);
        var separator2 = new Gtk.Separator (Gtk.Orientation.VERTICAL);
        var separator3 = new Gtk.Separator (Gtk.Orientation.VERTICAL);
        separator1.margin_left = 4;
        separator2.margin_left = 4;
        separator3.margin_left = 4;
        separator1.margin_right = 4;
        separator2.margin_right = 4;
        separator3.margin_right = 4;

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
        bool action_running = false;

        var image_sidebar_button = new Gtk.ToggleButton ();
        var image_icon = new Gtk.Image.from_icon_name ("image-x-generic", Gtk.IconSize.MENU);

        image_sidebar_button.set_tooltip_text (_("Page Images"));
        image_sidebar_button.get_style_context ().add_class ("flat");
        image_sidebar_button.can_focus = false;
        image_sidebar_button.hexpand = true;
        image_sidebar_button.halign = Gtk.Align.END;

        image_sidebar_button.add (image_icon);

        image_sidebar_button.toggled.connect (() => {
            if (action_running) return;
            action_running = true;

            if (plugin_sidebar.help_box == null) {
                plugin_sidebar.show (PlugSidebarWidget.HELP);

                plugin_sidebar.help_box.insert_requested.connect ((text) => {
                    code_buffer.insert_at_cursor (text, -1);
                });

                action_running = false;
                return;
            }

            if (image_sidebar_button.get_active ()) {
                plugin_sidebar.show (PlugSidebarWidget.IMAGES);
            } else {
                plugin_sidebar.close ();
            }

            action_running = false;
        });

        box.add (image_sidebar_button);

        var help_icon = new Gtk.Image.from_icon_name ("dialog-question-symbolic", Gtk.IconSize.MENU);

        help_button.set_tooltip_text (_("Formatting"));
        help_button.get_style_context ().add_class ("flat");
        help_button.can_focus = false;
        help_button.hexpand = false;
        help_button.halign = Gtk.Align.END;

        help_button.toggled.connect (() => {
            if (action_running) return;
            action_running = true;

            if (plugin_sidebar.help_box == null) {
                plugin_sidebar.show (PlugSidebarWidget.HELP);

                plugin_sidebar.help_box.insert_requested.connect ((text) => {
                    code_buffer.insert_at_cursor (text, -1);
                });

                action_running = false;
                return;
            }

            if (help_button.get_active ()) {
                plugin_sidebar.show (PlugSidebarWidget.HELP);
            } else {
                plugin_sidebar.close ();
            }

            action_running = false;
        });

        help_button.add (help_icon);
        box.add (help_button);

        plugin_sidebar.item_closed.connect ((type) => {
            switch (type) {
                case PlugSidebarWidget.HELP:
                    help_button.active = false;
                    break;
                case PlugSidebarWidget.IMAGES:
                    image_sidebar_button.active = false;
                    break;
            }
        });

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
