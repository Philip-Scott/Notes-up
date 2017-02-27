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

public class ENotes.Notebook : Object {
    public signal void destroy ();

    public int64 id;
    public int64? parent_id;

    public Gdk.RGBA rgb;
    public string name;
    public string css;
    public string stylesheet;

    public double r {
        get {
            return rgb.red;
        } set {
            rgb.red = value;
        }
    }

    public double g {
        get {
            return rgb.green;
        } set {
            rgb.green = value;
        }
    }

    public double b {
        get {
            return rgb.blue;
        } set {
            rgb.blue = value;
        }
    }
}

public class ENotes.NotebookTable : DatabaseTable {
    public signal void notebook_added (Notebook notebook);
    public signal void notebook_changed (Notebook notebook);

    private static NotebookTable instance = null;

    private NotebookTable () {
        var stmt = create_stmt ("CREATE TABLE IF NOT EXISTS Notebook ("
                                 + "id INTEGER PRIMARY KEY AUTOINCREMENT, "
                                 + "name TEXT NOT NULL, "
                                 + "rgb TEXT,"
                                 + "CSS TEXT,"
                                 + "stylesheet TEXT,"
                                 + "parent_id INTEGER)");
        var res = stmt.step ();
        if (res != Sqlite.DONE) {
            fatal ("create notebook table", res);
        }

        set_table_name ("Notebook");
    }

    public static NotebookTable get_instance () {
        if (instance == null) {
            instance = new NotebookTable ();
        }

        return instance;
    }

                     // ID, Notebook
    public Gee.ArrayList<Notebook> get_notebooks () {
        var stmt = create_stmt ("SELECT id, name, rgb, parent_id, css, stylesheet FROM Notebook");

        var notebooks = new Gee.ArrayList<Notebook>();

        for (;;) {
            var res = stmt.step ();
            if (res == Sqlite.DONE) {
                break;
            } else if (res != Sqlite.ROW) {
                fatal ("get_notebooks", res);
                break;
            }

            var row = new Notebook ();

            row.id = stmt.column_int64 (0);
            row.name = stmt.column_text (1);
            Gdk.RGBA rgba = {};
            rgba.parse (stmt.column_text (2));
            row.rgb = rgba;
            row.parent_id = stmt.column_int64 (3);
            row.css = stmt.column_text (4);
            row.stylesheet = stmt.column_text (5);

            notebooks.add (row);
        }

        return notebooks;
    }

    public Notebook? load_notebook_data (int64 notebook_id) {
       var stmt = create_stmt ("SELECT parent_id, name, rgb, css, stylesheet "
                      + "FROM Notebook WHERE id=?");

        bind_int (stmt, 1, notebook_id);

        if (stmt.step () != Sqlite.ROW)
            return null;

        var row = new Notebook ();
        row.id = notebook_id;
        row.parent_id = stmt.column_int (0);
        row.name = stmt.column_text (1);
        Gdk.RGBA rgba = {};
        rgba.parse (stmt.column_text (2));
        row.rgb = rgba;
        row.css = stmt.column_text (3);
        row.stylesheet = stmt.column_text (4);

        return row;
    }

    public void save_notebook (int64 notebook_id, string name, Gdk.RGBA rgb, string css, string stylesheet) {
        var stmt = create_stmt ("UPDATE Notebook SET name = ?, css = ?, stylesheet = ?, rgb =? WHERE id = ?");

        bind_text (stmt, 1, name);
        bind_text (stmt, 2, css);
        bind_text (stmt, 3, stylesheet);
        bind_text (stmt, 4, rgb.to_string ());
        bind_int (stmt, 5, notebook_id);

        stmt.step ();

        var notebook = load_notebook_data (notebook_id);
        notebook_changed (notebook);
    }

    public int64 new_notebook (int64 parent, string name, Gdk.RGBA rgb, string css, string stylesheet) {
        var stmt = create_stmt ("INSERT INTO Notebook (name, parent_id, rgb, css, stylesheet) "
                   + "VALUES (?, ?, ?, ?, ?)");

        bind_text (stmt, 1, name);
        bind_int (stmt, 2, parent);
        bind_text (stmt, 3, rgb.to_string ());
        bind_text (stmt, 4, css);
        bind_text (stmt, 5, stylesheet);

        var res = stmt.step ();
        if (res != Sqlite.DONE) {
            fatal ("Event create_from_row", res);
            return 0;
        }

        var last = last_insert_row ();
        var notebook = load_notebook_data (last);
        notebook_added (notebook);

        return last;
    }

    public string? get_stylesheet_from_page (int64 page_id) {
        var stmt = create_stmt ("SELECT stylesheet FROM Notebook JOIN Page WHERE Page.id = ? AND Page.notebook_id = Notebook.id");
        bind_int (stmt, 1, page_id);

        if (stmt.step () != Sqlite.ROW) {
            return null;
        }

        return stmt.column_text (0);
    }

    public string? get_css_from_page (int64 page_id) {
        var stmt = create_stmt ("SELECT css FROM Notebook JOIN Page WHERE Page.id = ? AND Page.notebook_id = Notebook.id");
        bind_int (stmt, 1, page_id);

        if (stmt.step () != Sqlite.ROW) {
            return null;
        }

        return stmt.column_text (0);
    }

    public void delete_notebook (int64 id) {
        var stmt = create_stmt ("UPDATE Notebook SET parent_id = 0 WHERE parent_id = ?");
        bind_int (stmt, 1, id);
        stmt.step ();

        stmt = create_stmt ("DELETE FROM Page WHERE notebook_id = ?");
        bind_int (stmt, 1, id);

        stmt.step ();

        stmt = create_stmt ("DELETE FROM Notebook WHERE id = ?");
        bind_int (stmt, 1, id);

        stmt.step ();
    }
}
