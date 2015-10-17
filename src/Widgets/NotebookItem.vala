public class ENotes.NotebookItem : Gtk.Button {
    private Gtk.Label label { get; private set;}
    private Gtk.Box box { get; private set;}
    private Gtk.Image color_dot;

    private static const int RADIUS = 16;
    private string notebook_name;
    private string notebook_dir;
    private string color;
    private double r;
    private double g;
    private double b;
    
    public NotebookItem (string notebook_name) {
        notebook_dir = notebook_name;
        split_string (notebook_name);

        build_ui ();
        connect_signals ();
    }

    private void split_string (string full_name) {
        var split = full_name.split ("§", 4);
        notebook_name = split[0];
        color = split[1];
        r = double.parse (split[1]);
        g = double.parse (split[2]);
        b = double.parse (split[3]);
        if (color == null) color = "cccccc";
    }

    private void build_ui () {
        this.can_focus = false;
        get_style_context ().add_class ("flat");
        
        color_dot = new Gtk.Image.from_pixbuf (get_color_dot (r,g,b, RADIUS, RADIUS));
        box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        label = new Gtk.Label (notebook_name);

        box.margin = 2;
        box.margin_end = 16;        
        
        box.add (color_dot);
        box.add (label);
        this.add (box);
        this.show_all ();
    }

    public static Gdk.Pixbuf get_color_dot (double r, double g, double b, int w, int h) {
        var surface = new Granite.Drawing.BufferSurface (w,h);
        Cairo.Context cr = surface.context;
        cr.set_source_rgba (r, g, b, 0.5);
        cr.translate (w/2, h/2);
        cr.arc (0, 0, (w/2)-2 , 0, 2 * GLib.Math.PI);
        cr.fill_preserve ();
        cr.set_line_width (1);
        cr.set_source_rgb (r, g, b);
        cr.stroke ();
        return surface.load_to_pixbuf ();
    }

    public void load () {
        stdout.printf ("Loading pages of %s\n", notebook_name);
        pages_list.load_pages (this.notebook_dir);
    }

    private void connect_signals () {
        this.clicked.connect (() => {
            this.load ();
        });
    }
}

