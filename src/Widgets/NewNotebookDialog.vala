public class ENotes.NotebookDialog : Gtk.Dialog {
	private Gtk.Entry name_entry;
	private Gtk.ColorButton color_button;
	private Gtk.Button create;
	
    public NotebookDialog () {
        build_ui ();
        connect_signals ();
        this.show_all ();
    }

    public void build_ui () {
        this.set_border_width (12);
		set_keep_above (true);
		set_size_request (360, 280);
		resizable = false;
        modal = true;

        var main_box 		= this.get_content_area();
		var title 			= new Gtk.Label ("<b>New Notebook</b>");
		var name_label 		= new Gtk.Label ("Name:");
		var color_label	    = new Gtk.Label ("Color:");
		title.set_use_markup (true);
		title.halign 		= Gtk.Align.START;
		name_label.halign 	= Gtk.Align.START;
		color_label.halign 	= Gtk.Align.START;
		
		name_entry = new Gtk.Entry ();
		color_button = new Gtk.ColorButton ();
					
		this.add_button ("Cancel", 2);
		create = (Gtk.Button) this.add_button ("Create", 1);
		create.sensitive = false;
		
		var grid = new Gtk.Grid ();
		grid.attach (title,			0,  0,  1,  1);
		grid.attach (name_label, 	0,	1, 	1,	1);
		grid.attach (name_entry,  	1,	1, 	1,	1);
		grid.attach (color_label, 	0,	2, 	1,	1);
		grid.attach (color_button, 	1,	2, 	1,	1);
		
		grid.set_column_homogeneous (false);
		grid.set_row_homogeneous (true);
		grid.row_spacing = 12;

		main_box.add (grid);
        
    }
    
    private void connect_signals () {
    	response.connect ((ID) => {
    		switch (ID) {
    			case 1: // Create Notebook
    			    //stderr.printf ("%f %f %f", color_button.rgba.red, color_button.rgba.green, color_button.rgba.blue );
    			    var r = color_button.rgba.red; var g = color_button.rgba.green; var b = color_button.rgba.blue;
    				var command = new Granite.Services.SimpleCommand ("/bin", @"mkdir $(NOTES_DIR)/$(name_entry.text)§%.4f§%.4f§%.4f".printf (r,g,b));
    				stderr.printf(@"mkdir $(NOTES_DIR)/$(name_entry.text)§%.4f§%.4f§%.4f".printf (r,g,b));
    				command.run ();
    				sidebar.load_notebooks ();
    				this.close ();
    				break;
    			case 2: // Cancel
    			
    			
    				break;	
    		}
    	});
    	
    	name_entry.notify["text"].connect (() => {
    		if (name_entry.text == "") {
    			create.sensitive = false;
    		} else {
    			create.sensitive = true;
    		}
	    	
    	});
    
    }
    
    
}
