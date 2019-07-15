/*
* Copyright (c) 2019 Felipe Escoto (https://github.com/Philip-Scott/Notes-up)
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

public class ENotes.BookmarkButton : Gtk.Button {
    private ENotes.Page current_page;
    private Gtk.Image pic;

    private bool starred {
        set {
            pic.set_from_icon_name (value ? "starred" : "non-starred", Gtk.IconSize.LARGE_TOOLBAR);
        }
    }

    public BookmarkButton () {
        pic = new Gtk.Image.from_icon_name ("non-starred",  Gtk.IconSize.LARGE_TOOLBAR);

        this.image = pic;

        expand = false;
        sensitive = false;
        can_focus = false;
        has_tooltip = true;
        set_tooltip_markup (Granite.markup_accel_tooltip (app.get_accels_for_action ("win.bookmark-action"), _("Bookmark page")));

        app.state.notify["opened-page"].connect (() => {
            var page = app.state.opened_page;

            if (page == null) {
                sensitive = false;
                starred = false;
                return;
            }

            sensitive = true;
            current_page = page;
            set_starred_from_current_page ();
        });

        app.state.bookmark_changed.connect (set_starred_from_current_page);

        clicked.connect (() => {
            main_action ();
        });
    }

    private void set_starred_from_current_page () {
        starred = BookmarkTable.get_instance ().is_bookmarked (this.current_page);
    }

    public void main_action () {
        if (BookmarkTable.get_instance ().is_bookmarked (this.current_page)) {
            BookmarkTable.get_instance ().remove (this.current_page.id);
        } else {
            BookmarkTable.get_instance ().add (this.current_page);
        }

        ENotes.Sidebar.get_instance ().load_bookmarks ();
        set_starred_from_current_page ();
    }
}
