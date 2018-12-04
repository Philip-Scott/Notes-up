/*
* Copyright (c) 2017 Felipe Escoto (https://github.com/Philip-Scott/Notes-up)
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

public class ENotes.HelpBox : Gtk.Revealer {
    public signal void insert_requested (string text);

    private Gtk.Grid grid;

    private int row = 0;

    public HelpBox () {
        transition_type = Gtk.RevealerTransitionType.SLIDE_LEFT;

        grid = new Gtk.Grid ();
        grid.margin = 12;
        grid.expand = false;

        var scroll_box = new Gtk.ScrolledWindow (null, null);
        scroll_box.get_style_context ().add_class ("list");
        scroll_box.hscrollbar_policy = Gtk.PolicyType.NEVER;
        scroll_box.add (grid);

        add_item (_("Large Header"), "h1", "\n# " );
        add_item (_("Medium Header"), "h2", "\n## ");
        add_item (_("Small Header"), "h3", "\n### ");

        add_item (_("<i>Italic</i>"), "", _("_italic_"));
        add_item (_("<b>Bold</b>"), "", _("**bold**"));
        add_item (_("<s>Strike</s>"), "", _("~~strike~~"));
        add_item (_("|  <i>quote</i>"), "", "> ");

        add_item (_("1. Numbered list"), "", "\n1. ");
        add_item (_("⚫ Bulleted list"), "", "\n- ");

        add_item (_("Divider"), "", "\n\n-----\n");
        add_item (_("Code"), "", "` code ` ");
        add_item (_("Code Block"), "", "\n\n```\n code \n```");
        add_item (_("Link"), "", _("[Text](www...) "));
        add_item (_("Citation Anchor"), "", "[^1]");
        add_item (_("Citation Text"), "", "\n[^1]: text");

        add_item (_("Youtube Video"), "", _("<youtube [link]>"));
        add_item (_("Page Break (when exporting)"), "", "<break>");
        add_item (_("Enable Syntax Highlighting"), "", "<highlight>");
        add_item (_("Set Color"), "", "<color #0099FF>");

        add (scroll_box);
        this.show_all ();
    }

    private void add_item (string _name, string _style_class, string _code) {
        var title = new Gtk.Label (_name);
        title.halign = Gtk.Align.START;
        title.set_use_markup (true);

        if (_style_class != "") {
            title.get_style_context ().add_class (_style_class);
        }

        var code = new Gtk.Label (_code.replace ("\n", ""));
        code.hexpand = true;
        code.halign = Gtk.Align.END;
        code.valign = Gtk.Align.CENTER;
        code.get_style_context ().add_class ("overlay-bar");
        code.get_style_context ().add_class ("h3");

        var item_button = new Gtk.Button ();
        item_button.get_style_context ().add_class ("flat");

        item_button.clicked.connect (() => {
            insert_requested (_code);
        });

        var item_grid = new Gtk.Grid ();
        item_grid.orientation = Gtk.Orientation.HORIZONTAL;
        item_grid.column_spacing = 6;
        item_grid.add (title);
        item_grid.add (code);

        item_button.add (item_grid);

        grid.attach (item_button, 0, row++, 1, 1);
        grid.attach (new Gtk.Separator (Gtk.Orientation.HORIZONTAL), 0, row++, 1, 1);
    }
}
