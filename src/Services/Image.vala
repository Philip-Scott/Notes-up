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

public class ENotes.Image : Object {
    public int64 id;
    public ImageFormat format;
    public string data;
}

public enum ENotes.ImageFormat {
  BITMAP = 0,
  VECTOR = 1;
  
  public static ENotes.ImageFormat get_format (int64 value) {
      return (value == 0) ? BITMAP : VECTOR;
  }
}

public class ENotes.ImageTable : DatabaseTable {

    private static ImageTable instance = null;

    public static ImageTable get_instance () {
        if (instance == null) {
            instance = new ImageTable ();
        }

        return instance;
    }

    private ImageTable () {
        var stmt = create_stmt ("CREATE TABLE IF NOT EXISTS Image ("
                                 + "id INTEGER NOT NULL, "
                                 + "page_id INTEGER NOT NULL, "
                                 + "format INTEGER, "
                                 + "data TEXT, "
                                 + "PRIMARY KEY (id, page_id))");
        var res = stmt.step ();

        if (res != Sqlite.DONE) {
            fatal ("create image table", res);
        }

        set_table_name ("Image");
    }

    public int64 save (int64 page_id, int64 format, string data) {
        var count_stmt = create_stmt ("SELECT count(*) FROM Image WHERE page_id = ?");
        bind_int (count_stmt, 1, page_id);
        count_stmt.step ();

        var new_image_id = count_stmt.column_int64 (0) + 1;

        var stmt = create_stmt ("INSERT INTO Image (id, page_id, format, data) values (?, ?, ?, ?)");
        bind_int (stmt, 1, new_image_id);
        bind_int (stmt, 2, page_id);
        bind_int (stmt, 3, format);
        bind_text (stmt, 4, data);
        stmt.step ();

        return new_image_id;
    }

    public ENotes.Image? get_image (int64 page_id, int64 photo_id) {
        var image = new ENotes.Image ();
        
        var stmt = create_stmt ("SELECT format, data FROM Image WHERE page_id = ? AND id = ?");
        bind_int (stmt, 1, page_id);
        bind_int (stmt, 2, photo_id);
        
        var res = stmt.step ();
        if (res == Sqlite.DONE) {
            return null;
        }
        
        image.id = photo_id;
        image.format = ENotes.ImageFormat.get_format (stmt.column_int64 (0));
        image.data = stmt.column_text (1);
       
        return image;
    }
}
