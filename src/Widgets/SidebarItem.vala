public class ENotes.SidebarItem :  Granite.Widgets.SourceList.ExpandableItem {
    private static const int RADIUS = 16;

    protected void set_color (ENotes.Notebook nb) {
        if (nb.r > -1) {
    	    var surface = new Granite.Drawing.BufferSurface (RADIUS, RADIUS);
            Cairo.Context cr = surface.context;
            cr.set_source_rgba (nb.r, nb.g, nb.b, 0.5);
            cr.translate (RADIUS / 2, RADIUS / 2);
            cr.arc (0, 0, (RADIUS / 2 ) - 2 , 0, 2 * GLib.Math.PI);
            cr.fill_preserve ();
            cr.set_line_width (1.3);
            cr.set_source_rgb (nb.r, nb.g, nb.b);
	    	cr.stroke ();

	    	icon = surface.load_to_pixbuf ();
		}
	}
}
