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

public class ENotes.Viewer : WebKit.WebView {
    public static string[] STYLES = {_("Default"), ("elementary"), _("Air"), _("Modest")};

    private static Viewer? instance = null;

    public string CSS;
    private string previous_path = "";
    private Page? previous_page = null;
    private File temp_file;

    public static Viewer get_instance () {
        if (instance == null) {
            instance = new Viewer ();
        }

        return instance;
    }

    private Viewer () {
        string file = "/tmp/notes-up-render-" + GLib.Environment.get_user_name ();
        temp_file = File.new_for_path (file);

        connect_signals ();
    }

    public void load_css (ENotes.Page? page, bool overrride = false) {
        if (overrride || previous_path != page.path) {
            if (page != null) previous_path = page.path;

            var stylesheet = Notebook.get_styleshet (previous_path);
            set_styleshet (stylesheet);
        }
    }

    private void set_styleshet (string stylesheet, bool trying_global = false) {
        switch (stylesheet) {
            case "elementary": CSS = Styles.elementary.css; break;
            case "Modest": CSS = Styles.modest.css; break;
            case "Air": CSS = Styles.air.css; break;
            default:
                if (trying_global == false) {
                    set_styleshet (ENotes.settings.stylesheet, true);
                } else {
                    CSS = Styles.elementary.css;
                }
                break;
        }


        if (!trying_global) {
            CSS = CSS + ENotes.settings.render_stylesheet + Notebook.get_styleshet_changes (previous_path);
        }
    }

    public new void reload () {
        if (previous_page != null) {
            load_css (previous_page, true);
            load_page (previous_page);
        }
    }

    public void load_page (Page page, bool force_load = false) {
        if (ViewEditStack.current_mode == Mode.VIEW || force_load) {
            debug ("Viewer loading: %s", page.name);

            previous_page = page;

            string html;

            process_frontmatter (page.get_text (), out html);
            load_css (page);

            try {
                FileManager.write_file(temp_file, process (html), true);
                load_uri (temp_file.get_uri ());
            } catch (Error e) {
                load_html ("<h1>Sorry....</h1> <h2>Loading your file failed :(</h2> <br>", null);
            }
        } else {
            previous_page = page;
            load_css (page);
        }
    }

    private void connect_signals () {
        load_changed.connect ((event) => {
            if (event == WebKit.LoadEvent.FINISHED) {
                var rectangle = get_window_properties ().get_geometry ();
                set_size_request (rectangle.width, rectangle.height);
            }
        });
    }

    private string[] process_frontmatter (string raw_mk, out string processed_mk) {
        string[] map = {};

        processed_mk = null;

        // Parse frontmatter
        if (raw_mk.length > 4 && raw_mk[0:4] == "---\n") {
            int i = 0;
            bool valid_frontmatter = true;
            int last_newline = 3;
            int next_newline;
            string line = "";
            while (true) {
                next_newline = raw_mk.index_of_char('\n', last_newline + 1);
                if (next_newline == -1) { // End of file
                    valid_frontmatter = false;
                    break;
                }

                line = raw_mk[last_newline+1:next_newline];
                last_newline = next_newline;

                if (line == "---") { // End of frontmatter
                    break;
                }

                var sep_index = line.index_of_char(':');
                if (sep_index != -1) {
                    map += line[0:sep_index-1];
                    map += line[sep_index+1:line.length];
                } else { // No colon, invalid frontmatter
                    valid_frontmatter = false;
                    break;
                }

                i++;
            }

            if (valid_frontmatter) { // Strip frontmatter if it's a valid one
                processed_mk = raw_mk[last_newline:raw_mk.length];
            }
        }

        if (processed_mk == null) {
            processed_mk = raw_mk;
        }

        return map;
    }

    private string process (string raw_mk) {
        string processed_mk;
        process_frontmatter (raw_mk, out processed_mk);
                                                        //Extra Footnote + Autolink + ``` code + Extra def lists + keep style + Table of conentes
        var mkd = new Markdown.Document (processed_mk.data, 0x00200000 + 0x00004000 + 0x02000000 + 0x01000000 + 0x00400000);
        mkd.compile (0x00200000 + 0x00004000 + 0x02000000 + 0x01000000 + 0x00400000);

        string result;
        mkd.get_document (out result);

        string html = "<!doctype html><meta charset=utf-8><head>";
        html += "<style>"+ CSS +"</style>";
        html += "</head><body><div class=\"markdown-body\">";
        html += result;
        html += "</div></body></html>";

        return html;
    }
}
