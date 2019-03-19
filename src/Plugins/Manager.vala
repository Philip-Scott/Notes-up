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
        plug_list += new Break ();
        plug_list += new Highlight ();
        plug_list += new ImagePlugin ();
        plug_list += new PageLink ();
    }

    public unowned Plugin[] get_plugs () {
        return plug_list;
    }

    public Gee.List<BLMember>? get_all_blacklist_members () {
        var result = new Gee.LinkedList<BLMember> ();
        foreach (Plugin plugin in plug_list){
            if (plugin.get_blacklist_members () != null) {
                foreach (BLMember blacklist_member in plugin.get_blacklist_members ()) {
                    result.add (blacklist_member);
                }
            }
        }
        return result;
    }
}
