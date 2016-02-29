public class ENotes.Headerbar : Gtk.HeaderBar { 
    public signal void mode_changed (bool editor);

    private Granite.Widgets.ModeButton mode_button;
    private Granite.Widgets.AppMenu menu_button;
    private Gtk.MenuItem item_new;
    private Gtk.MenuItem item_preff;
    private Gtk.MenuItem item_export;

    public Headerbar () {
        build_ui ();
        connect_signals ();
    }
    
    private void build_ui () {
        mode_button = new Granite.Widgets.ModeButton ();
        mode_button.append_text (("View"));
        mode_button.append_text (("Edit"));
        mode_button.valign = Gtk.Align.CENTER;
        
        var menu = new Gtk.Menu ();
 		item_new   = new Gtk.MenuItem.with_label (_("New Notebook"));
 		item_preff = new Gtk.MenuItem.with_label (_("Preferences"));
 		item_export = new Gtk.MenuItem.with_label (_("Export to PDF"));
 		menu.add (item_new);
 		menu.add (item_export);
        menu.add (item_preff);

 		menu_button = new Granite.Widgets.AppMenu (menu);

        set_title (null);
        set_show_close_button (true);
        pack_start (mode_button);
        pack_end (menu_button);
    }
    
    public int get_mode () {
        return mode_button.selected;
    }
        
    public void set_mode (int mode) {
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
                mode_changed (false);
                editor.save_file ();
            } else {
                mode_changed (true);
            }
        });
    }
}
