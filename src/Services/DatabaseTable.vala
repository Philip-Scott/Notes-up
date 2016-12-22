/* Copyright 2009-2013 Yorba Foundation
 *
 * This software is licensed under the GNU LGPL (version 2.1 or later).
 * See the COPYING file in this distribution.
 */

public errordomain DatabaseError {
    ERROR,
    BACKING,
    MEMORY,
    ABORT,
    LIMITS,
    TYPESPEC
}

namespace Db {

    public const string IN_MEMORY_NAME = ":memory:";

    private string? filename = null;

    // Passing null as the db_file will create an in-memory, non-persistent database.
    public void preconfigure (File? db_file) {
        filename = (db_file != null) ? db_file.get_path () : IN_MEMORY_NAME;
    }

    public void init () throws Error {
        assert (filename != null);

        DatabaseTable.init (filename);
    }

    public void terminate () {
        DatabaseTable.terminate ();
    }

    public enum VerifyResult {
        OK,
        FUTURE_VERSION,
        UPGRADE_ERROR,
        NO_UPGRADE_AVAILABLE
    }

    public VerifyResult verify_database (out string app_version, out int schema_version) {
        return VerifyResult.OK;
    }
}

public abstract class DatabaseTable {
    /***
     * This number should be incremented every time any database schema is altered.
     *
     * NOTE: Adding or removing tables or removing columns do not need a new schema version, because
     * tables are created on demand and tables and columns are easily ignored when already present.
     * However, the change should be noted in upgrade_database () as a comment.
     ***/
    public const int SCHEMA_VERSION = 21;

    protected static Sqlite.Database db;

    private static int in_transaction = 0;

    public string table_name = null;

    private static void prepare_db (string filename) {
        // Open DB.
        int res = Sqlite.Database.open_v2 (filename, out db, Sqlite.OPEN_READWRITE | Sqlite.OPEN_CREATE,
                                           null);
        assert (res == Sqlite.OK);

        // Check if we have write access to database.
        if (filename != Db.IN_MEMORY_NAME) {
            try {
                File file_db = File.new_for_path (filename);
                FileInfo info = file_db.query_info (FileAttribute.ACCESS_CAN_WRITE, FileQueryInfoFlags.NONE);
                assert (info.get_attribute_boolean (FileAttribute.ACCESS_CAN_WRITE));

            } catch (Error e) {
                error ("Error accessing database file:\n %s\n\n Error was: \n%s", filename, e.message);
            }
        }
    }

    public static void init (string filename) {
        // Open DB.
        prepare_db (filename);
        GLib.warning ("NAME: %s", filename);

        // Try a query to make sure DB is intact; if not, try to use the backup
        Sqlite.Statement stmt;
        int res = db.prepare_v2 ("CREATE TABLE IF NOT EXISTS VersionTable ("
                                 + "id INTEGER PRIMARY KEY, "
                                 + "schema_version INTEGER, "
                                 + "app_version TEXT, "
                                 + "user_data TEXT NULL"
                                 + ")", -1, out stmt);

        // Query on db failed, copy over backup and open it
        if (res != Sqlite.OK) {
            db = null;

            string backup_path = filename + ".bak";
            string cmdline = "cp " + backup_path + " " + filename;
            //Posix.system (cmdline);

            prepare_db (filename);
        }

        // disable synchronized commits for performance reasons ... this is not vital, hence we
        // don't error out if this fails
        res = db.exec ("PRAGMA synchronous=OFF");
        if (res != Sqlite.OK)
            warning ("Unable to disable synchronous mode", res);
    }

    public static void terminate () {
        // freeing the database closes it
        db = null;
    }

    // XXX: errmsg () is global, and so this will not be accurate in a threaded situation
    protected static void fatal (string op, int res) {
        error ("%s: [%d] %s", op, res, db.errmsg ());
    }

    // XXX: errmsg () is global, and so this will not be accurate in a threaded situation
    protected static void warning (string op, int res) {
        GLib.warning ("%s: [%d] %s", op, res, db.errmsg ());
    }

    protected void set_table_name (string table_name) {
        this.table_name = table_name;
    }

    // This method will throw an error on an SQLite return code unless it's OK, DONE, or ROW, which
    // are considered normal results.
    protected static void throw_error (string method, int res) throws DatabaseError {
        string msg = "(%s) [%d] - %s".printf (method, res, db.errmsg ());

        switch (res) {
        case Sqlite.OK:
        case Sqlite.DONE:
        case Sqlite.ROW:
            return;

        case Sqlite.PERM:
        case Sqlite.BUSY:
        case Sqlite.READONLY:
        case Sqlite.IOERR:
        case Sqlite.CORRUPT:
        case Sqlite.CANTOPEN:
        case Sqlite.NOLFS:
        case Sqlite.AUTH:
        case Sqlite.FORMAT:
        case Sqlite.NOTADB:
            throw new DatabaseError.BACKING (msg);

        case Sqlite.NOMEM:
            throw new DatabaseError.MEMORY (msg);

        case Sqlite.ABORT:
        case Sqlite.LOCKED:
        case Sqlite.INTERRUPT:
            throw new DatabaseError.ABORT (msg);

        case Sqlite.FULL:
        case Sqlite.EMPTY:
        case Sqlite.TOOBIG:
        case Sqlite.CONSTRAINT:
        case Sqlite.RANGE:
            throw new DatabaseError.LIMITS (msg);

        case Sqlite.SCHEMA:
        case Sqlite.MISMATCH:
            throw new DatabaseError.TYPESPEC (msg);

        case Sqlite.ERROR:
        case Sqlite.INTERNAL:
        case Sqlite.MISUSE:
        default:
            throw new DatabaseError.ERROR (msg);
        }
    }

    protected static Sqlite.Statement create_stmt (string data) {
        debug ("Running statement: %s\n", data);

        Sqlite.Statement stmt;
        int res = db.prepare_v2 (data, -1, out stmt);
        assert_test (res == Sqlite.OK, data);

        return stmt;
    }

    protected static void bind_text (Sqlite.Statement stmt, int column, string data) {
        var res = stmt.bind_text (column, data);
        assert (res == Sqlite.OK);
    }

    protected static void bind_int (Sqlite.Statement stmt, int column, int64 data) {
        var res = stmt.bind_int64 (column, data);
        assert (res == Sqlite.OK);
    }

    private static void assert_test (bool condition, string data) {
        if (!condition) {
            stderr.printf ("Assertion failed: %s\n", data);
        }

        assert (condition);
    }

    protected bool exists_by_id (int64 id) {
        var stmt = create_stmt ("SELECT id FROM %s WHERE id=?".printf (table_name));

        bind_int (stmt, 1, id);

        var res = stmt.step ();
        if (res != Sqlite.ROW && res != Sqlite.DONE)
            fatal ("exists_by_id [%s] %s".printf (id.to_string (), table_name), res);

        return (res == Sqlite.ROW);
    }

    protected bool select_by_id (int64 id, string columns, out Sqlite.Statement stmt) {
        stmt = create_stmt ("SELECT %s FROM %s WHERE id=?".printf (columns, table_name));

        bind_int (stmt, 1, id);

        var res = stmt.step ();
        if (res != Sqlite.ROW && res != Sqlite.DONE)
            fatal ("select_by_id [%s] %s %s".printf (id.to_string (), table_name, columns), res);

        return (res == Sqlite.ROW);
    }

    // Caller needs to bind value #1 before calling execute_update_by_id ()
    private void prepare_update_by_id (int64 id, string column, out Sqlite.Statement stmt) {
        stmt = create_stmt ("UPDATE %s SET %s=? WHERE id=?".printf (table_name, column));

        var res = stmt.bind_int64 (2, id);
        assert (res == Sqlite.OK);
    }

    private bool execute_update_by_id (Sqlite.Statement stmt) {
        int res = stmt.step ();
        if (res != Sqlite.DONE) {
            fatal ("execute_update_by_id", res);

            return false;
        }

        return true;
    }

    protected bool update_text_by_id (int64 id, string column, string text) {
        Sqlite.Statement stmt;
        prepare_update_by_id (id, column, out stmt);

        int res = stmt.bind_text (1, text);
        assert (res == Sqlite.OK);

        return execute_update_by_id (stmt);
    }

    protected void update_text_by_id_2 (int64 id, string column, string text) throws DatabaseError {
        Sqlite.Statement stmt;
        prepare_update_by_id (id, column, out stmt);

        int res = stmt.bind_text (1, text);
        assert (res == Sqlite.OK);

        res = stmt.step ();
        if (res != Sqlite.DONE)
            throw_error ("DatabaseTable.update_text_by_id_2 %s.%s".printf (table_name, column), res);
    }

    protected bool update_int_by_id (int64 id, string column, int value) {
        Sqlite.Statement stmt;
        prepare_update_by_id (id, column, out stmt);

        int res = stmt.bind_int (1, value);
        assert (res == Sqlite.OK);

        return execute_update_by_id (stmt);
    }

    protected void update_int_by_id_2 (int64 id, string column, int value) throws DatabaseError {
        Sqlite.Statement stmt;
        prepare_update_by_id (id, column, out stmt);

        int res = stmt.bind_int (1, value);
        assert (res == Sqlite.OK);

        res = stmt.step ();
        if (res != Sqlite.DONE)
            throw_error ("DatabaseTable.update_int_by_id_2 %s.%s".printf (table_name, column), res);
    }

    protected bool update_int64_by_id (int64 id, string column, int64 value) {
        Sqlite.Statement stmt;
        prepare_update_by_id (id, column, out stmt);

        int res = stmt.bind_int64 (1, value);
        assert (res == Sqlite.OK);

        return execute_update_by_id (stmt);
    }

    protected void update_int64_by_id_2 (int64 id, string column, int64 value) throws DatabaseError {
        Sqlite.Statement stmt;
        prepare_update_by_id (id, column, out stmt);

        int res = stmt.bind_int64 (1, value);
        assert (res == Sqlite.OK);

        res = stmt.step ();
        if (res != Sqlite.DONE)
            throw_error ("DatabaseTable.update_int64_by_id_2 %s.%s".printf (table_name, column), res);
    }

    protected void delete_by_id (int64 id) throws DatabaseError {
        var stmt = create_stmt ("DELETE FROM %s WHERE id=?".printf (table_name));

        var res = stmt.bind_int64 (1, id);
        assert (res == Sqlite.OK);

        res = stmt.step ();
        if (res != Sqlite.DONE)
            throw_error ("%s.remove".printf (table_name), res);
    }

    public static bool has_column (string table_name, string column_name) {
        var stmt = create_stmt ("PRAGMA table_info(%s)".printf (table_name));

        for (;;) {
            var res = stmt.step ();
            if (res == Sqlite.DONE) {
                break;
            } else if (res != Sqlite.ROW) {
                fatal ("has_column %s".printf (table_name), res);

                break;
            } else {
                string column = stmt.column_text (1);
                if (column != null && column == column_name)
                    return true;
            }
        }

        return false;
    }

    public static bool has_table (string table_name) {
        var stmt = create_stmt ("PRAGMA table_info(%s)".printf (table_name));

        var res = stmt.step ();

        return (res != Sqlite.DONE);
    }

    public static bool add_column (string table_name, string column_name, string column_constraints) {
        Sqlite.Statement stmt;
        int res = db.prepare_v2 ("ALTER TABLE %s ADD COLUMN %s %s".printf (table_name, column_name,
                                 column_constraints), -1, out stmt);
        assert (res == Sqlite.OK);

        res = stmt.step ();
        if (res != Sqlite.DONE) {
            critical ("Unable to add column %s %s %s: (%d) %s", table_name, column_name, column_constraints,
                      res, db.errmsg ());

            return false;
        }

        return true;
    }

    public int64 last_insert_row () {
        var stmt = create_stmt ("SELECT last_insert_rowid()");

        var res = stmt.step ();
        if (res != Sqlite.ROW) {
            critical ("Unable to retrieve last row on %s: (%d) %s", table_name, res, db.errmsg ());

            return 0;
        }

        return stmt.column_int64 (0);
    }

    // This method will only add the column if a table exists (relying on the table object
    // to build a new one when first referenced) and only if the column does not exist.  In essence,
    // it's a cleaner way to run has_table (), has_column (), and add_column ().
    public static bool ensure_column (string table_name, string column_name, string column_constraints,
                                      string upgrade_msg) {
        if (!has_table (table_name) || has_column (table_name, column_name))
            return true;

        message ("%s", upgrade_msg);

        return add_column (table_name, column_name, column_constraints);
    }

    public int get_row_count () {
        var stmt = create_stmt ("SELECT COUNT(id) AS RowCount FROM %s".printf (table_name));

        var res = stmt.step ();
        if (res != Sqlite.ROW) {
            critical ("Unable to retrieve row count on %s: (%d) %s", table_name, res, db.errmsg ());

            return 0;
        }

        return stmt.column_int (0);
    }

    // This is not thread-safe.
    public static void begin_transaction () {
        if (in_transaction++ != 0)
            return;

        int res = db.exec ("BEGIN TRANSACTION");
        assert (res == Sqlite.OK);
    }

    // This is not thread-safe.
    public static void commit_transaction () throws DatabaseError {
        assert (in_transaction > 0);
        if (--in_transaction != 0)
            return;

        int res = db.exec ("COMMIT TRANSACTION");
        if (res != Sqlite.DONE)
            throw_error ("commit_transaction", res);
    }
}

