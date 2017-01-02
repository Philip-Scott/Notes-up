/*
* Copyright (c) 2016 Felipe Escoto (https://github.com/Philip-Scott/Notes-up)
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

public class ENotes.PluginManager : GLib.Object {
    private static PluginManager? instance = null;

    private Plugin[] plug_list = {};
    
    private PluginManager () {
        
    }
    
    public static PluginManager get_instance () {
        if (instance == null) {
            instance = new PluginManager ();
            instance.load_plugins ();
        }
        
        return instance;
    }
    
    private void load_plugins () {
        // TODO: Load dynamically from plugins directory        
        plug_list += new Color ();
        plug_list += new Youtube ();
    }
    
    public List<Plugin> get_plugs () {
        var plugs = new List<Plugin> ();

        foreach (var plugin in plug_list) {
            if (plugin.is_active ()) {
                plugs.append (plugin);
            }
        }
        
        return plugs;
    }
} 
