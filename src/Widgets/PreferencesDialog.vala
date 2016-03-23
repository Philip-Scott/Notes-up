public class ENotes.PreferencesDialog : Gtk.Dialog {
    private Gtk.FontButton font_button;
    private Gtk.ListStore schemes_store;
    private Gtk.TreeIter schemes_iter;
    private Gtk.ComboBox scheme_box;
    private Gtk.TextView style_box;
    private Gtk.Stack stack;
    private Gtk.Switch indent_switch;
    private Gtk.Switch line_numbers_switch;

    public PreferencesDialog () {
        build_ui ();
        connect_signals ();
    }

    private void build_ui () {
        this.set_border_width (12);
        this.title = _("Preferences");
        this.window_position = Gtk.WindowPosition.CENTER;

        set_size_request (590, 530);
        resizable = false;
        modal = true;

        stack = new Gtk.Stack ();
        stack.add_titled (editor_grid (), "editor", _("Editor"));
        stack.add_titled (viewer_grid (), "viewer", _("Viewer"));
        stack.set_margin_top (12);

        var switcher = new Gtk.StackSwitcher ();
        switcher.set_stack (stack);
        switcher.halign = Gtk.Align.CENTER;

        var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);

        box.add (switcher);
        box.add (stack);
        this.get_content_area().add (box);

        add_button ("_Close", Gtk.ResponseType.CLOSE);

        this.show_all ();
    }

    private Gtk.Grid editor_grid () {
        var grid = new Gtk.Grid ();

        var font_label = new Gtk.Label (_("Font:"));
        font_label.set_halign (Gtk.Align.END);
        font_button = new Gtk.FontButton ();
        font_button.use_font = true;
        font_button.use_size = true;

        if (settings.editor_font != "") {
            font_button.set_font_name (settings.editor_font);
        }

        var scheme_label = new Gtk.Label (_("Theme:"));
        scheme_label.set_halign (Gtk.Align.END);

        schemes_store = new Gtk.ListStore (2, typeof (string), typeof (string));

        scheme_box = new Gtk.ComboBox.with_model (schemes_store);
        var scheme_renderer = new Gtk.CellRendererText ();
        scheme_box.pack_start (scheme_renderer, true);
        scheme_box.add_attribute (scheme_renderer, "text", 1);

        var schemes = get_source_schemes ();
        int i = 0;

        schemes_iter = {};
        foreach (var scheme in schemes) {
            schemes_store.append (out schemes_iter);
            schemes_store.set (schemes_iter, 0, scheme.id, 1, scheme.name);

            if (scheme.id == settings.editor_scheme) {
                scheme_box.active = i;
            }

            i++;
        }

        var indent_label = new Gtk.Label (_("Automatic indentation:"));
        indent_label.set_halign (Gtk.Align.END);
        indent_switch = new Gtk.Switch ();
        indent_switch.state = settings.auto_indent;

        var switch_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        switch_box.add (indent_switch);

        var line_numbers_label = new Gtk.Label (_("Show line Numbers:"));
        line_numbers_label.set_halign (Gtk.Align.END);
        line_numbers_switch = new Gtk.Switch ();
        line_numbers_switch.state = settings.line_numbers;

        var switch_box_ln = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        switch_box_ln.add (line_numbers_switch);

        grid.attach (font_label,        0, 1, 1, 1);
        grid.attach (font_button,       1, 1, 2, 1);
        grid.attach (scheme_label,      0, 2, 1, 1);
        grid.attach (scheme_box,        1, 2, 2, 1);
        grid.attach (indent_label,      0, 3, 1, 1);
        grid.attach (switch_box,        1, 3, 1, 1);
        grid.attach (line_numbers_label,0, 4, 1, 1);
        grid.attach (switch_box_ln,     1, 4, 1, 1);

        grid.set_column_homogeneous (false);
        grid.set_row_homogeneous (false);
        grid.row_spacing = 6;
        grid.column_spacing = 12;

        return grid;
    }

    private Gtk.Grid viewer_grid () {
        var title = new Gtk.Label ("<b>%s</b>".printf(_("Global Stylesheet")));
        title.set_use_markup (true);
        title.set_halign (Gtk.Align.START);

        style_box = new Gtk.TextView ();
        style_box.set_wrap_mode (Gtk.WrapMode.WORD);
        style_box.set_hexpand (true);
        style_box.set_vexpand (true);
        style_box.buffer.text = settings.render_stylesheet;

        var scrolled = new Gtk.ScrolledWindow (null, null);
        scrolled.add (style_box);

        var grid = new Gtk.Grid ();
        grid.set_column_homogeneous (false);
        grid.set_row_homogeneous (false);
        grid.row_spacing = 8;
        grid.column_spacing = 8;

        grid.attach (title, 0, 0, 1, 1);
        grid.attach (scrolled, 0, 1 ,1, 1);
        return grid;
    }

    private void connect_signals () {
        indent_switch.state_set.connect ((state) => {
            settings.auto_indent = state;
            return false;
        });

        line_numbers_switch.state_set.connect ((state) => {
            settings.line_numbers = state;

            editor.show_line_numbers (state);
            return false;
        });

        font_button.font_set.connect (() => {
            unowned string name = font_button.get_font_name ();
            settings.editor_font = name;

            editor.set_font (name);
        });

        scheme_box.changed.connect(() => {
            Value box_val;
            scheme_box.get_active_iter (out schemes_iter);
            schemes_store.get_value (schemes_iter, 0, out box_val);

            var scheme_id = (string) box_val;
            settings.editor_scheme = scheme_id;

            editor.set_scheme (scheme_id);
        });

        this.response.connect (on_response);
    }

    private void on_response (Gtk.Dialog source, int response_id) {
        switch (response_id) {
            case Gtk.ResponseType.CLOSE:
                settings.render_stylesheet = style_box.buffer.text;
                viewer.load_css ();
                viewer.load_string (editor.get_text ());
                editor.load_settings ();
                destroy ();
            break;
        }
    }

    private Gtk.SourceStyleScheme[] get_source_schemes () {
        var style_manager = Gtk.SourceStyleSchemeManager.get_default ();
        unowned string[] scheme_ids = style_manager.get_scheme_ids ();
        Gtk.SourceStyleScheme[] schemes = {};

        foreach (string id in scheme_ids) {
            schemes += style_manager.get_scheme (id);
        }

        return schemes;
    }
}
