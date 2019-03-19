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

public class ENotes.Tag : Object {
    public int64 id = -1;
    public string name;
    public string data;
}

public class ENotes.TagsTable : DatabaseTable {
    private static TagsTable instance = null;

    public static TagsTable get_instance () {
        if (instance == null) {
            instance = new TagsTable ();
        }

        return instance;
    }

    private TagsTable () {
        var stmt = create_stmt ("CREATE TABLE IF NOT EXISTS Tags ("
            + "id INTEGER PRIMARY KEY AUTOINCREMENT, "
            + "name TEXT UNIQUE NOT NULL DEFAULT '', "
            + "data TEXT NOT NULL DEFAULT '')");

        var res = stmt.step ();

        if (res != Sqlite.DONE)
            fatal ("Failed to create tag table", res);

        stmt = create_stmt ("CREATE TABLE IF NOT EXISTS TagsPage ("
            + "page_id INTEGER, "
            + "tag_id INTEGER)");

        res = stmt.step ();

        if (res != Sqlite.DONE)
            fatal ("Failed to create tag table", res);


        set_table_name ("Tags");
    }

    public Gee.ArrayList<Tag>? get_tags_for_page (int64 page_id) {
        var stmt = create_stmt ("SELECT id, name, data"
                             + "FROM Tags tag"
                             + "INNER JOIN TagsPage tp"
                             + "   ON tp.tag_id = tag.id"
                             + "WHERE tp.page_id = ?");

        bind_int (stmt, 1, page_id);

        var tags = new Gee.ArrayList<Tag>();

        for (;;) {
            var res = stmt.step ();
            if (res == Sqlite.DONE) {
                break;
            } else if (res != Sqlite.ROW) {
                fatal ("get_all_tags", res);
                break;
            }

            var row = new Tag ();

            row.id = stmt.column_int64 (0);
            row.name = stmt.column_text (1);
            row.data = stmt.column_text (2);

            tags.add (row);
        }

        return tags;
    }

    public void create_tag (string name) {
        var stmt = create_stmt ("INSERT INTO Tags (name) VALUES (?)");
        bind_text (stmt, 1, name);

        var res = stmt.step ();
    }

    public void save_tag (Tag tag) {

    }

    public Gee.ArrayList<Tag> get_tags () {
        var stmt = create_stmt ("SELECT id, name, data FROM Tags");

        var tags = new Gee.ArrayList<Tag>();

        for (;;) {
            var res = stmt.step ();
            if (res == Sqlite.DONE) {
                break;
            } else if (res != Sqlite.ROW) {
                fatal ("get_all_tags", res);
                break;
            }

            var row = new Tag ();

            row.id = stmt.column_int64 (0);
            row.name = stmt.column_text (1);
            row.data = stmt.column_text (2);

            tags.add (row);
        }

        return tags;
    }

    public Gee.ArrayList<Page> get_pages_for_tag (Tag tag) {
        var stmt = create_stmt ("SELECT id, name, subtitle "
                            + "FROM Page p "
                            + "INNER JOIN TagsPage tp "
                            + "   ON tp.page_id = p.id "
                            + "WHERE tp.tag_id = ?");

        bind_int (stmt, 1, tag.id);

        var pages = new Gee.ArrayList<Page>();

        for (;;) {
            var res = stmt.step ();
            if (res == Sqlite.DONE) {
                break;
            } else if (res != Sqlite.ROW) {
                fatal ("get_pages_for_tag", res);
                break;
            }

            var row = new Page ();

            row.id = stmt.column_int64 (0);
            row.name = stmt.column_text (1);
            row.subtitle = stmt.column_text (2);

            pages.add (row);
        }

        return pages;
    }

}
