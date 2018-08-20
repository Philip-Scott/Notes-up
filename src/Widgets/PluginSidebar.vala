/*
* Copyright (c) 2018 Felipe Escoto (https://github.com/Philip-Scott/Notes-up)
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

public enum ENotes.PlugSidebarWidget {
    HELP = 0,
    IMAGES = 1
}

public class ENotes.PluginSidebar : Gtk.Revealer {
    public signal void item_closed (PlugSidebarWidget type);

    private static PluginSidebar? instance = null;

    private PlugSidebarWidget? opened = null;
    private Gtk.Stack stack;

    public ENotes.HelpBox? help_box = null;
    public ENotes.HelpBox? image_box = null;

    public static PluginSidebar get_instance () {
        if (instance == null) {
            instance = new PluginSidebar ();
        }

        return instance;
    }

    construct {
        transition_type = Gtk.RevealerTransitionType.SLIDE_LEFT;
        stack = new Gtk.Stack ();

        var scroll_box = new Gtk.ScrolledWindow (null, null);
        scroll_box.get_style_context ().add_class ("list");
        scroll_box.hscrollbar_policy = Gtk.PolicyType.NEVER;
        scroll_box.add (stack);
        scroll_box.vexpand = true;

        var box = new Gtk.Grid ();
        box.orientation = Gtk.Orientation.HORIZONTAL;
        box.add (new Gtk.Separator (Gtk.Orientation.VERTICAL));
        box.add (scroll_box);
        add (box);
    }

    public void show (PlugSidebarWidget type) {
        if (opened != null) {
            item_closed (opened);
        }

        switch (type) {
            case PlugSidebarWidget.HELP:
                show_help ();
                break;
            case PlugSidebarWidget.IMAGES:
                show_images ();
                break;
        }

        set_reveal_child (true);
        opened = type;
    }

    private void show_help () {
        if (help_box == null) {
            help_box = new HelpBox ();
            stack.add_named (help_box, PlugSidebarWidget.HELP.to_string ());
            show_all ();
        }

        stack.set_visible_child_full (
            PlugSidebarWidget.HELP.to_string (),
            Gtk.StackTransitionType.SLIDE_LEFT
        );
    }

    private void show_images () {
        if (image_box == null) {
            image_box = new HelpBox ();
            stack.add_named (image_box, PlugSidebarWidget.IMAGES.to_string ());
            show_all ();
        }

        stack.set_visible_child_full (
            PlugSidebarWidget.HELP.to_string (),
            Gtk.StackTransitionType.SLIDE_LEFT
        );
    }

    public void close () {
        set_reveal_child (false);
        opened = null;
    }
}