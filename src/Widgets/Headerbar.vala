public class ENotes.Headerbar : Gtk.HeaderBar { 
    public signal void mode_changed (bool editor);

    private Granite.Widgets.ModeButton mode_button;
    private Granite.Widgets.AppMenu menu_button;
    private Gtk.MenuItem item_new;
    private Gtk.MenuItem item_preff;
    private Gtk.MenuItem item_export;
    private Gtk.MenuItem item_about;

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
 		item_new   = new Gtk.MenuItem.with_label ("New Notebook");
 		item_preff = new Gtk.MenuItem.with_label ("Preferences");
 		item_export = new Gtk.MenuItem.with_label ("Export Page");
 		item_about = new Gtk.MenuItem.with_label ("About");
 		menu.add (item_new);
 		menu.add (item_export);
        menu.add (item_preff);
        menu.add (item_about);
         		
 		menu_button = new Granite.Widgets.AppMenu (menu);

        set_show_close_button (true);
        pack_start (mode_button);
        pack_end (menu_button);
    }
    
    public int get_mode () {
        return mode_button.selected;
    }
        
    public void set_app_mode (int mode) {
    	mode_button.set_active (mode);
    }    
        
    public void set_mode (string mode) {
        switch (mode) {
            case "edit": 
                mode_button.set_active (1); break;
            case "view":
                mode_button.set_active (0); break;
        }
    }
    
    private void connect_signals () {
    	item_export.activate.connect (() => {
            file_manager.export_pdf_action ();
        });    
    
        item_new.activate.connect (() => {
            var dialog = new NotebookDialog ();
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
