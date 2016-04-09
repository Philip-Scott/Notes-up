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
public interface ENotes.Plugin : Object {
	public abstract void registered (PluginLoader loader);
	public abstract void activated ();
	public abstract void deactivated ();

	public abstract string get_desctiption (); //Description of the plugin
	public abstract string get_name ();		   //Plugin name
	public abstract string get_key ();		   //What the module looks for in order to convert
	
	public abstract string convert (string line);	//Once the viewer finds the key, it will call this function
}
