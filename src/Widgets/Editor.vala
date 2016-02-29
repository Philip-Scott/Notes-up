public class ENotes.Editor : Gtk.Box {
    private Gtk.SourceView code_view;
    private Gtk.SourceBuffer code_buffer;

    private bool edited = false;

    public ENotes.Page current_page = null;

    public Editor () {
        build_ui ();
        reset ();
        load_settings ();
    }

    public void load_file (ENotes.Page page) {
        code_buffer.begin_not_undoable_action ();

        save_file ();
        if (page.name == _("New Page")) {
            headerbar.set_mode (1);
        }

	    current_page = page;
        code_buffer.text = page.load_text ();
        viewer.load_string (this.get_text ());
        edited = false;
        headerbar.set_title (page.name);

        code_buffer.end_not_undoable_action ();
        this.set_sensitive (true);
    }

    public void save_file () {
        if (edited) {
        	edited = false;
            if (current_page != null) {
                current_page.save_file (this.get_text ());
            }
        }
    }

    public void set_text (string text, bool new_file = false) {
        if (new_file) {
            code_buffer.changed.disconnect (trigger_changed);
        }

        code_buffer.text = text;

        if (new_file) {
            code_buffer.changed.connect (trigger_changed);
        }
    }

    public void restore () {
    	if (current_page != null) {
    	    edited = false;
    	    load_file (current_page);
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

    private void build_ui () {
        var manager = Gtk.SourceLanguageManager.get_default ();
        var language = manager.guess_language (null, "text/x-markdown");
        code_buffer = new Gtk.SourceBuffer.with_language (language);
        code_buffer.set_max_undo_levels (100);

        code_view = new Gtk.SourceView.with_buffer (code_buffer);

        set_size_request (250,50);
        expand = true;

        code_buffer.changed.connect (trigger_changed);

        code_view.left_margin = 5;
        code_view.pixels_above_lines = 5;
        code_view.wrap_mode = Gtk.WrapMode.WORD;
        code_view.show_line_numbers = true;

	    var scroll_box = new Gtk.ScrolledWindow (null, null);
	    scroll_box.add (code_view);

	    this.set_orientation (Gtk.Orientation.VERTICAL);
	    this.add (build_toolbar ());
	    this.add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
        this.add (scroll_box);
        this.set_sensitive (false);
	    scroll_box.expand = true;
            this.show_all ();
        }

        private Gtk.Box build_toolbar () {
        var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
	    //box.get_style_context ().add_class ("header");
	    //box.get_style_context ().add_class ("notebook");

	    var bold_button = ToolbarButton ("format-text-bold", "**", "**", _("Add bold to text"));
	    var italics_button = ToolbarButton ("format-text-italic", "_", "_", _("Add italic to text"));
	    var srike_button = ToolbarButton ("format-text-strikethrough", "~~~", "~~~", _("Strikethrough text"));

	    var quote_button = ToolbarButton ("format-indent-less-rtl", "> ", "", _("Insert a quote"));
	    var code_button = ToolbarButton ("system-run", "`", "`", _("Insert code"));
	    var link_button = ToolbarButton ("insert-link", "[", "](url)", _("Insert a link"));

	    var bulleted_button = ToolbarButton ("zoom-out","\n- ", "", _("Add a bulleted list"));
	    var numbered_button = ToolbarButton ("zoom-original","\n1. ", "", _("Add a Numbered list"));

	    //var button_iframe = ToolbarButton ("system-run","", "", "Insert a website");
	    var webimage_button = ToolbarButton ("insert-image","![](", ")", _("Insert a web image"));

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
       	box.add (srike_button);
       	box.add (separator1);
       	box.add (quote_button);
       	box.add (code_button);

       	box.add (bulleted_button);
       	box.add (numbered_button);
       	box.add (separator2);
       	box.add (link_button);
       	box.add (webimage_button);
       	box.add (separator3);

        return box;
    }

    private Gtk.Button ToolbarButton (string icon, string first_half, string second_half, string description = "") {
    	var button = new Gtk.Button.from_icon_name(icon, Gtk.IconSize.SMALL_TOOLBAR);
	    button.can_focus = false;
    	button.get_style_context ().add_class ("flat");
	    button.set_tooltip_text (description);

	    button.clicked.connect (() => {
	    	if (code_buffer.has_selection) {
		    	Gtk.TextIter start, end;
		    	code_buffer.get_selection_bounds (out start, out end);

		    	var text = start.get_text (end);
		    	code_buffer.@delete (ref start, ref end);
		    	code_buffer.insert_at_cursor (first_half + text + second_half, -1);
		    } else {
		    	Gtk.TextIter start, end;
		    	code_buffer.insert_at_cursor (first_half, -1);

		    	code_buffer.get_selection_bounds (out start, out end);
		    	code_buffer.insert (ref end, second_half , -1);

		    	code_buffer.place_cursor (start);
		    }
	    });

	    return button;
    }
}
