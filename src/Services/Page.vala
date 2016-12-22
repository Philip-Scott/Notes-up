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

public class ENotes.Page : Object {
    public int64 id = -1;
    public int64 notebook_id = -1;
    public string name;
    public string data;
    public string subtitle;
    public string html_cache;
    public int64 creation_date;
    public int64 modification_date;

    public bool new_page = false;

    public bool is_bookmarked () { return false; }
    public string full_path = "";

    public bool equals (Page page) {
        return this.id == page.id;
    }

    public string get_text () {
        return data;
    }
}

public class ENotes.PageTable : DatabaseTable {
    public signal void page_saved (Page page);

    private static PageTable instance = null;

    public static PageTable get_instance () {
        if (instance == null) {
            instance = new PageTable ();
        }

        return instance;
    }

    private PageTable () {
        var stmt = create_stmt ("CREATE TABLE IF NOT EXISTS Page ("
                                 + "id INTEGER PRIMARY KEY AUTOINCREMENT, "
                                 + "name TEXT NOT NULL DEFAULT '', "
                                 + "data TEXT NOT NULL DEFAULT '', "
                                 + "subtitle TEXT NOT NULL DEFAULT '', "
                                 + "html_cache TEXT NOT NULL DEFAULT '', "
                                 + "creation_date INTEGER,"
                                 + "modification_date INTEGER,"
                                 + "notebook_id INTEGER)");
        var res = stmt.step ();

        if (res != Sqlite.DONE)
            fatal ("create page table", res);

        // index on event_id
        stmt = create_stmt ("CREATE INDEX IF NOT EXISTS NotebookIDIndex ON Page (notebook_id)");

        res = stmt.step ();
        if (res != Sqlite.DONE) {
            fatal ("create page table", res);
        }

        set_table_name ("Page");
    }

    public Page? get_page (int64 page_id) {
        var stmt = create_stmt ("SELECT name, data, subtitle, html_cache, creation_date, modification_date, "
                      + "notebook_id "
                      + "FROM Page WHERE id = ?");

        bind_int (stmt, 1, page_id);

        if (stmt.step () != Sqlite.ROW)
            return null;

        Page row = new Page ();
        row.id = page_id;
        row.name = stmt.column_text (0);
        row.data = stmt.column_text (1);
        row.subtitle = stmt.column_text (2);
        row.html_cache = stmt.column_text (3);
        row.creation_date = stmt.column_int64 (4);
        row.modification_date = stmt.column_int64 (5);
        row.notebook_id = stmt.column_int64 (6);

        return row;
    }

    public void save_page (Page page) {
        var stmt = create_stmt ("UPDATE Page SET name = ?, subtitle = ?, data = ?, html_cache = ?, modification_date =? WHERE id = ?");
        load_page_info (page);

        bind_text (stmt, 1, page.name);
        bind_text (stmt, 2, page.subtitle);
        bind_text (stmt, 3, page.data);
        bind_text (stmt, 4, "");
        bind_int (stmt, 5, Gdk.CURRENT_TIME);
        bind_int (stmt, 6, page.id);
        stmt.step ();
        
        page_saved (page);
    }

    public void save_cache (Page page) {
        var stmt = create_stmt ("UPDATE Page SET html_cache = ? WHERE id = ?");
        bind_text (stmt, 1, page.html_cache);
        bind_int (stmt, 2, page.id);
        stmt.step ();
    }

    public Page new_page (int64 notebook_id) {
         var stmt = create_stmt ("INSERT INTO Page (notebook_id, name, creation_date, modification_date) "
                       + "VALUES (?, ?, ?, ?)");

         bind_int (stmt, 1, notebook_id);
         bind_text (stmt, 2, _("New Page"));
         bind_int (stmt, 3, Gdk.CURRENT_TIME);
         bind_int (stmt, 4, Gdk.CURRENT_TIME);

         stmt.step ();

         return get_page (last_insert_row ());
    }

    public Gee.ArrayList<Page> get_pages (int64 notebook_id) {
        var stmt = create_stmt ("SELECT id, name, subtitle, data FROM Page Where notebook_id = ?");
        bind_int (stmt, 1, notebook_id);

        var pages = new Gee.ArrayList<Page>();

        for (;;) {
            var res = stmt.step ();
            if (res == Sqlite.DONE) {
                break;
            } else if (res != Sqlite.ROW) {
                fatal ("get_notebooks", res);
                break;
            }

            var row = new Page ();

            row.id = stmt.column_int64 (0);
            row.name = stmt.column_text (1);
            row.subtitle = stmt.column_text (2);
            row.data = stmt.column_text (3);

            pages.add (row);
        }

        return pages;
    }

    public bool is_bookmarked () {
        return false;
    }

    private void load_page_info (Page page) {
        string line[2];
        string[] lines;

        lines = page.data.split ("\n");

        if (lines.length > 0) {
            page.name = cleanup(lines[0]);

            for(int n = 0, i = 1; i < lines.length && n < 1; i++) {
                line[n] = cleanup (lines[i]);
                if (line[n] != "") {
                    n++;
                }
            }
        } else {
            page.name = _("New Page");
        }

        if (line[0] != null) {
            page.subtitle = convert(line[0]);
        } else {
            page.subtitle = "";
        }
    }

    private string cleanup (string line) {
        string output = line;

        if (line.contains ("---")) return "";

        string[] blacklist = {"#", "```", "\t", "<br>", ">", "<", "\n"};
        foreach (string item in blacklist) {
            if (output.contains (item)) {
                output = output.replace (item, "");
            }
        }

        if (output.contains ("&")) output = output.replace ("&","&amp;");

        if (output.length > 0 && output[0] == ' ') {
            output = output[1:output.length];
        }

        return output;
    }

    private bool bold_state;
    private bool italics_state;
    private string convert (string raw_content) {
        bold_state = true;
        italics_state = true;

        if (raw_content == null || raw_content == "") return "";
        if (!raw_content.contains ("\n")) return raw_content;

        var lines = raw_content.split ("\n", -1);

        string final = "";
        foreach (string line in lines) {
            while (line.contains ("----")) { //Line cleanup
                line = line.replace ("----", "---");
            }

            if (line.contains ("	")) {
                line = line.replace ("	", "&nbsp;&nbsp;&nbsp;&nbsp;");
            }

            if (line.contains ("**")) {
                line = replace (line, "**", "<b>", "</b>", ref bold_state);
            }

            if (line.contains ("_")) {
                line = replace (line, "_", "<i>", "</i>", ref italics_state);
            }

            final = final + line;
        }

        return final;
    }

    private string replace (string line_, string looking_for, string opening, string closing, ref bool type_state) {
        int chars = line_.length;
        int replace_size = looking_for.length;
        string line = line_ + "     ";

        StringBuilder final = new StringBuilder ();
        for (int i = 0; i < chars; i++) {
            if (line[i:i + replace_size] == looking_for) {
                if (type_state) {
                    type_state = false;
                    final.append (opening);
                } else {
                    type_state = true;
                    final.append (closing);
                }
                i = i + replace_size - 1;

            }  else {
                final.append (line[i:i+1]);
            }
        }

        return final.str;
    }
}
