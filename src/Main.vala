/***
    Copyright (C) 2015 Felipe Escoto <felescoto95@hotmail.com>

    This program is free software: you can redistribute it and/or modify it
    under the terms of the GNU Lesser General Public License version 3, as published
    by the Free Software Foundation.

    This program is distributed in the hope that it will be useful, but
    WITHOUT ANY WARRANTY; without even the implied warranties of
    MERCHANTABILITY, SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR
    PURPOSE. See the GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along
    with this program. If not, see <http://www.gnu.org/licenses/>.
***/

public static const string APP_NAME = "Notes";
public static const string TERMINAL_NAME = "Notes";

public static int main (string[] args) {
    /* Initiliaze gettext support */
    Intl.setlocale (LocaleCategory.ALL, Intl.get_language_names ()[0]);
    //Intl.textdomain (Config.GETTEXT_PACKAGE);

    Environment.set_application_name (APP_NAME);
    Environment.set_prgname (APP_NAME);

    var application = new ENotes.Application ();

    return application.run (args);
}


