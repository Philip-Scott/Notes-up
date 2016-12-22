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

public class ENotes.Bookmark : Object {
    public signal void destroy ();

    public string name;
    private string link;

    public ENotes.Page page { public get; private set; }
    private File bookmark_file;

    public Bookmark.from_link (string link) {
        this.link = link;

        setup (link);
    }

    public Bookmark.from_page (ENotes.Page page) {
        this.page = page;

        link = ENotes.NOTES_DIR + page.full_path.replace (ENotes.NOTES_DIR, "").replace ("/", ".");
        setup (link);
    }

    private void setup (string link) {
        this.bookmark_file = File.new_for_path (link);

        try {
            string target = this.bookmark_file.query_info (FileAttribute.STANDARD_NAME + "," + FileAttribute.STANDARD_SYMLINK_TARGET, 0).get_symlink_target ();
//            page = new ENotes.Page (target);

            if (page.new_page) return;
        } catch (Error e) {
            stderr.printf ("Symlink has no target: %s", e.message);
            return;
        }

        this.name = page.name;
    }

    public void bookmark () {
        FileUtils.symlink (page.full_path, link);
    }

    public void unbookmark () {
        try {
            bookmark_file.@delete ();
        } catch (Error e) {
            stderr.printf ("Could not delete bookmark: %s", e.message);
        }

        destroy ();
    }
}
