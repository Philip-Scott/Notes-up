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
    public int64 page_id;
    public string name;
    public Gdk.RGBA color;
}

public class ENotes.BookmarkTable : DatabaseTable {
    public signal void bookmark_added ();
    public signal void bookmark_removed (int64 bookmark_id);

    private static BookmarkTable instance = null;

    public static BookmarkTable get_instance () {
        if (instance == null) {
            instance = new BookmarkTable ();
        }

        return instance;
    }

    private BookmarkTable () {
        var stmt = create_stmt ("CREATE TABLE IF NOT EXISTS Bookmark ("
                                 + "id INTEGER UNIQUE PRIMARY KEY, "
                                 + "name TEXT)");
        var res = stmt.step ();

        if (res != Sqlite.DONE) {
            fatal ("create bookmark table", res);
        }

        set_table_name ("Bookmark");
    }

    public void add (Page page) {
        var stmt = create_stmt ("INSERT INTO Bookmark (id) values (?)");
        bind_int (stmt, 1, page.id);
        stmt.step ();

        bookmark_added ();
    }

    public void remove (int64 page_id) {
        var stmt = create_stmt ("DELETE FROM Bookmark Where id = ?");
        bind_int (stmt, 1, page_id);
        stmt.step ();

        bookmark_removed (page_id);
    }

    public Gee.ArrayList<Bookmark> get_bookmarks () {
        var stmt = create_stmt ("SELECT Page.id, Page.name, Notebook.rgb, Bookmark.name "
                                + "FROM Bookmark JOIN Page on Bookmark.id = Page.id "
                                + "JOIN Notebook on page.notebook_id = Notebook.id");

        var bookmarks = new Gee.ArrayList<Bookmark>();

        for (;;) {
            var res = stmt.step ();
            if (res == Sqlite.DONE) {
                break;
            } else if (res != Sqlite.ROW) {
                fatal ("get bookmarks", res);
                break;
            }

            var row = new Bookmark ();

            row.page_id = stmt.column_int64 (0);

            if (stmt.column_text (3) != null) {
                row.name = stmt.column_text (3);
            } else {
                row.name = stmt.column_text (1);
            }

            Gdk.RGBA rgba = {};
            rgba.parse (stmt.column_text (2));
            row.color = rgba;

            bookmarks.add (row);
        }

        return bookmarks;
    }

    public void rename (int64 id, string text) {
        var stmt = create_stmt ("UPDATE Bookmark SET name = ? WHERE id = ?");
        bind_text (stmt, 1, text);
        bind_int (stmt, 2, id);
        stmt.step ();
    }

    public bool is_bookmarked (Page? page) {
        var stmt = create_stmt ("SELECT CAST(CASE WHEN COUNT(*) > 0 THEN 1 ELSE 0 END AS INTEGER) FROM Bookmark WHERE Bookmark.id = ?");
        bind_int (stmt, 1, page.id);
        stmt.step ();

        return stmt.column_int64 (0) == 1;
    }

    public static void reset_instance () {
        instance = null;
    }
}
