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

    public bool cache_changed = false;

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

    // This list is used for complex commands mostly by plugins e.g. "" <youtube [Link]>
    private Gee.LinkedList<BLMember> regex_complex_commands = new Gee.LinkedList<BLMember> ();

    // regex_simple_elements used for symbols. Some symbols are part of more complex commands so these
    // list is used at the end
    // first regular expression replaces # ~ ` etc. with ""
    BLMember[] regex_simple_elements = {new BLMember (/[#\n\t<>`]+/, ""), new BLMember(/<br>/, "")};

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
        ///This code summarises a notebook page. Instead of given youtube link this code changes into Youtube Video

        // Explaination for link: Regex for [Something](Something). As greedy as editor on markdown
        var link = new BLMember(/\[[\p{L}\d_\.\?\/:\=\+&\-'" ]*\]\([\p{L}\d_\.\?\/:\=\+&\-'"]*\)/, ""); // "

        //  \[\^\d+\]:? leads to e.g. [^32], [^68]:
        var anchor = new BLMember (/\[\^\d+\]:?/, "");

        regex_complex_commands = (Gee.LinkedList) PluginManager.get_instance ().get_all_blacklist_members ();
        regex_complex_commands.add (link);
        regex_complex_commands.add (anchor);

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
        var stmt = create_stmt ("UPDATE Page SET name = ?, subtitle = ?, data = ?, html_cache = ?, modification_date = CAST(strftime('%s', 'now') AS INT) WHERE id = ?");
        load_page_info (page);

        bind_text (stmt, 1, page.name);
        bind_text (stmt, 2, page.subtitle);
        bind_text (stmt, 3, page.data);
        bind_text (stmt, 4, page.html_cache);
        bind_int (stmt, 5, page.id);
        stmt.step ();

        page_saved (page);
    }

    public void move_to_notebook (Page page, int64 notebook) {
        var stmt = create_stmt ("UPDATE Page SET notebook_id = ?, modification_date = CAST(strftime('%s', 'now') AS INT) WHERE id = ?");
        load_page_info (page);

        bind_int (stmt, 1, notebook);
        bind_int (stmt, 2, page.id);
        stmt.step ();
    }

    // Clears cache on pages where $id = notebook_id; 0 for clearing all
    public void clear_cache_on (int64 id) {
        Sqlite.Statement stmt;
        stderr.printf ("Clearing cache on: %d\n", (int) id);
        if (id > 0) {
            stmt = create_stmt ("UPDATE Page SET html_cache = ? WHERE notebook_id = ?");
            bind_text (stmt, 1, "");
            bind_int (stmt, 2, id);
            stmt.step ();
        } else {
            stmt = create_stmt ("UPDATE Page SET html_cache = ?");
            bind_text (stmt, 1, "");
            stmt.step ();
        }
    }

    public Page new_page (int64 notebook_id) {
         var stmt = create_stmt ("INSERT INTO Page (notebook_id, name, creation_date, modification_date) "
                       + "VALUES (?, ?, CAST(strftime('%s', 'now') AS INT), CAST(strftime('%s', 'now') AS INT))");

         bind_int (stmt, 1, notebook_id);
         bind_text (stmt, 2, _("New Page"));

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

    public Gee.ArrayList<Page> get_all_pages () {
        var stmt = create_stmt ("SELECT id, name, subtitle, data FROM Page");

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

    public void delete_page (int64 id) {
        ImageTable.get_instance ().delete_all_from_page (id);
        TagsTable.get_instance ().remove_tags_from_page (id);
        BookmarkTable.get_instance ().remove (id);

        var stmt = create_stmt ("DELETE FROM Page WHERE id = ?");
        bind_int (stmt, 1, id);

        stmt.step ();
    }

    public bool is_bookmarked () {
        return false;
    }

    private void load_page_info (Page page) {
        string[] lines;

        lines = page.data.split ("\n");
        string preview = "";

        if (lines.length > 0) {
            if (page.name == _("New Page")) {
                page.name = cleanup (lines[0]);
            }

            for (int i = 1; i < lines.length; i++) {
                preview = cleanup (lines[i]);
                if (preview != "") {
                    break;
                }
            }
        } else if (lines.length == 0){
            page.name = _("New Page");
        }

        if (preview != null) {
            page.subtitle = convert(preview);
        } else {
            page.subtitle = "";
        }
    }

    private string cleanup (string line) {
        string output = line;

        try {
            foreach (var item in regex_complex_commands) {
                output = item.reg.replace (output, -1, 0, item.replace);
            }

            foreach (var item in regex_simple_elements) {
                output = item.reg.replace (output, -1, 0, item.replace);
            }
        } catch (GLib.RegexError e) {
            return "";
        }

        if (line.contains ("---")) return "";

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

        var line = raw_content;

        if (line.contains ("	")) {
            line = line.replace ("	", "&nbsp;&nbsp;&nbsp;&nbsp;");
        }

        if (line.contains ("**")) {
            line = replace (line, "**", "<b>", "</b>", ref bold_state);
        }

        if (line.contains ("_")) {
            line = replace (line, "_", "<i>", "</i>", ref italics_state);
        }

        return line;
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

    public static void reset_instance () {
        instance = null;
    }
}
