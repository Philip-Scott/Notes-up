/*
* Copyright (c) 2016 Felipe Escoto (https://github.com/Philip-Scott/Notes-up)
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

public class ENotes.Trash : Object {
    public signal void page_added (ENotes.Page page);
    public signal void page_removed (ENotes.Page page);
    public signal void notebook_added (ENotes.Notebook notebook);
    public signal void notebook_removed (ENotes.Notebook notebook);

    private static Trash? instance = null;

    private Trash () {
    }

    public static Trash get_instance () {
        if (instance == null) {
            instance = new Trash ();
        }

        return instance;
    }

    public void trash_page (ENotes.Page page) {
    }

    public void trash_notebook (ENotes.Notebook notebook) {
    }

    public void restore_page (ENotes.Page page) {
    }

    public void restore_notebook (ENotes.Notebook notebook) {
        Sidebar.get_instance ().load_notebooks ();
    }

    public bool is_page_trashed (ENotes.Page to_check) {
        return false;
    }

    public bool is_notebook_trashed (ENotes.Notebook to_check) {
        return false;
    }

    public void clear_files () {

    }
}
