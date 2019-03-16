/*
* Copyright (c) 2011-2016 Felipe Escoto (https://github.com/Philip-Scott/Notes-up)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 59 Temple Place - Suite 330,
* Boston, MA 02111-1307, USA.
*
* Authored by: Felipe Escoto <felescoto95@hotmail.com>
*/

public class ENotes.SidebarItem :  Granite.Widgets.SourceListPatch.ExpandableItem {
    private const int RADIUS = 16;

    protected void set_color (Gdk.RGBA rgba) {
        if (rgba.red > -1) {
    	    var surface = new Granite.Drawing.BufferSurface (RADIUS, RADIUS);
            Cairo.Context cr = surface.context;
            cr.set_source_rgba (rgba.red, rgba.green, rgba.blue, 0.5);
            cr.translate (RADIUS / 2, RADIUS / 2);
            cr.arc (0, 0, (RADIUS / 2 ) - 2 , 0, 2 * GLib.Math.PI);
            cr.fill_preserve ();
            cr.set_line_width (1.3);
            cr.set_source_rgb (rgba.red, rgba.green, rgba.blue);
	    	cr.stroke ();

	    	icon = surface.load_to_pixbuf ();
		}
	}
}
