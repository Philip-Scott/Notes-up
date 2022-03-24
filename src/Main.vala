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


public static int main (string[] args) {
    /* Initialize gettext support */
    GLib.Intl.setlocale (LocaleCategory.ALL, "");
    GLib.Intl.bindtextdomain (Constants.GETTEXT_PACKAGE, Constants.LOCALEDIR);
    GLib.Intl.bind_textdomain_codeset (Constants.GETTEXT_PACKAGE, "UTF-8");
    GLib.Intl.textdomain (Constants.GETTEXT_PACKAGE);

    Environment.set_application_name (N_("Notes-Up"));
    Environment.set_prgname (Constants.PROJECT_NAME);

    var application = new ENotes.Application ();

    return application.run (args);
}

