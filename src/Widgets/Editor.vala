public class ENotes.Editor : Gtk.ScrolledWindow {
    public Gtk.SourceView code_view;
    private Gtk.SourceBuffer code_buffer;

    private bool edited = false;

    public Editor () {
        set_size_request (250,50);
        expand = true;
        setup_code_view ();
        reset ();
        set_scheme ("tango");
        
        //editor.code_view.activate.connect (() => {});
    }

    public void load_file (string file_path, string file_name) {
        save_file ();
        if (file_name == "New Page") {
            headerbar.set_mode ("edit");
            
        } 
        code_buffer.text = file_manager.load_file (file_path, file_name);     
        edited = false;
        viewer.load_string (this.get_text ());
    }

    public void save_file () {
        if (edited == false) return;
        file_manager.save_file ();
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

    public void reset (bool disable_save = false) {
        if (disable_save) edited = false;
        code_buffer.text = "";
    }

    public string get_text () {
        return code_view.buffer.text;
    }

    public void give_focus () {
        code_view.grab_focus ();
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

    private string get_default_scheme () {
        var style_manager = Gtk.SourceStyleSchemeManager.get_default ();
        if ("solarized-dark" in style_manager.scheme_ids) { // In Gnome
            return "solarized-dark";
        } else { // In Elementary
            return "solarizeddark";
        }
    }

    private void trigger_changed () {
        edited = true;
    }

    private void setup_code_view () {
        var manager = Gtk.SourceLanguageManager.get_default ();
        var language = manager.guess_language (null, "text/x-markdown");
        code_buffer = new Gtk.SourceBuffer.with_language (language);
        code_buffer.set_max_undo_levels (100);

        code_view = new Gtk.SourceView.with_buffer (code_buffer);

        code_buffer.changed.connect (trigger_changed);

        code_view.left_margin = 5;
        code_view.pixels_above_lines = 5;
        code_view.wrap_mode = Gtk.WrapMode.WORD;
        code_view.show_line_numbers = true;

        this.set_scheme (this.get_default_scheme ());

        add (code_view);
    }
} 
