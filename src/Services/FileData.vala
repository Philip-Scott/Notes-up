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

public enum FileDataType {
    FILE_NAME = 0,
    LAST_NOTEBOOK = 10,
    LAST_PAGE = 11,
    STYLESHEET = 21,
    CUSTOM_CSS = 22
}

public class ENotes.FileDataTable : DatabaseTable {
    private static FileDataTable _instance;
    public static FileDataTable instance {
        get {
            if (_instance == null) {
                _instance = new FileDataTable ();
            }

            return _instance;
        }
    }

    private FileDataTable () {
        var stmt = create_stmt ("CREATE TABLE IF NOT EXISTS FileData ("
                                 + "id INTEGER UNIQUE PRIMARY KEY, "
                                 + "value TEXT)");
        var res = stmt.step ();

        if (res != Sqlite.DONE) {
            fatal ("create bookmark table", res);
        }

        set_table_name ("FileData");
    }

    // If NULL, value was not initialized
    public string? get_value (FileDataType type) {
        var stmt = create_stmt ("SELECT value FROM FileData WHERE id=?");
        bind_int (stmt, 1, type);

        var res = stmt.step ();
        if (res == Sqlite.DONE) {
            return null;
        }

        return stmt.column_text (0);
    }

    public int64 get_int64 (FileDataType type) {
        var value = get_value (type);

        if (value == null) {
            return 0;
        } else {
            return int64.parse (value);
        }
    }

    public void set_value (FileDataType type, string value) {
        set_value_silent (type, value);
        app.state.file_data_changed (type, value);
    }

    public void set_value_silent (FileDataType type, string value) {
        var stmt = create_stmt ("INSERT OR REPLACE INTO FileData"
                                + "(id, value) VALUES(?, ?)");
        bind_int (stmt, 1, type);
        bind_text (stmt, 2, value);
        stmt.step ();
    }
}
