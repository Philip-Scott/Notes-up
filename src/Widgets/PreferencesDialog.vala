public class ENotes.PreferencesDialog : Gtk.Dialog {
    private Gtk.FontButton font_button;
    private Gtk.ListStore schemes_store;
    private Gtk.TreeIter schemes_iter;
    private Gtk.ComboBox scheme_box;

    public PreferencesDialog () {
        build_ui ();
        connect_signals ();
    }

    private void build_ui () {
        this.set_border_width (12);
		set_keep_above (true);
		set_size_request (360, 280);
		resizable = false;
        modal = true;

        var box = this.get_content_area();
        var grid = new Gtk.Grid ();
		this.title = _("Preferences");
		this.window_position = Gtk.WindowPosition.CENTER;

		// Editor Preffs:
		font_button = new Gtk.FontButton ();
        font_button.use_font = true;
        font_button.use_size = true;

        if (settings.editor_font != "") {
            font_button.set_font_name (settings.editor_font);
        }

        var font_label = new Gtk.Label ("Font");
        var scheme_label = new Gtk.Label ("Theme");
        var title = new Gtk.Label ("<b>Editor</b>");
        title.set_use_markup (true);

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

        grid.attach (title,				0,  0,  1,  1);
		grid.attach (font_label, 		0,	1, 	1,	1);
		grid.attach (font_button,  		1,	1, 	1,	1);
		grid.attach (scheme_label, 	    0,	2, 	1,	1);
		grid.attach (scheme_box,  	    1,	2, 	1,	1);


		grid.set_column_homogeneous (false);
		grid.set_row_homogeneous (true);
		grid.row_spacing = 8;
		grid.column_spacing = 8;

        box.add (grid);
        box.show_all ();
    }

    private void connect_signals () {
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
