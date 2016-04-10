public class ENotes.Headerbar : Gtk.HeaderBar { 
    public signal void mode_changed (bool editor);
    public signal void search_changed ();
    public signal void search_selected ();

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

        search_button = new Gtk.Button.from_icon_name("edit-find-symbolic", Gtk.IconSize.LARGE_TOOLBAR);
        search_button.has_tooltip = true;
        search_button.tooltip_text = _("Search your current notebook");
        search_button.clicked.connect(show_search);

        search_button_revealer.add(search_button);
        search_entry_revealer.add(search_entry);
        search_entry_revealer.reveal_child = false;
        search_button_revealer.reveal_child = true;

        set_title (null);
        set_show_close_button (true);

        pack_start (mode_button);
        pack_end (menu_button);
        pack_end (search_entry_revealer);
        pack_end (search_button_revealer);

        this.show_all ();
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
                pages_list.grab_focus ();
            } else {
                mode_changed (true);
                editor.give_focus ();
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
