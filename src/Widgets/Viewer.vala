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
    private static Viewer? instance = null;

    public string CSS;
    private Page? previous_page = null;
    private StyleLoader style_loader;

    public static Viewer get_instance () {
        if (instance == null) {
            instance = new Viewer ();
        }

        return instance;
    }

    private Viewer () {
        style_loader = StyleLoader.instance;
        connect_signals ();
    }

    public void load_css (ENotes.Page? page, bool overrride = false) {
        if (overrride || previous_page == null || previous_page.id != page.id) {
            if (page != null) previous_page = page;


            if (previous_page != null) {
                var stylesheet = NotebookTable.get_instance ().get_stylesheet_from_page (previous_page.id);
                CSS = style_loader.get_styleshet (stylesheet, previous_page.id);
            }
        }
    }

    public new void reload () {
        if (previous_page != null) {
            load_css (previous_page, true);
            load_page (previous_page, true);
        }
    }

    public void load_page (Page page, bool force_load = false) {
        if (ViewEditStack.current_mode == Mode.VIEW || force_load) {
            if (page.html_cache == "" || force_load) {
                string markdown;
                process_frontmatter (page.data, out markdown);
                load_css (page);
                page.html_cache = process (markdown);

                PageTable.get_instance ().save_cache (page);
            }

            load_html (page.html_cache, "file:///");
        }
    }

    private void connect_signals () {
        create.connect ((navigation_action) => {
            launch_browser (navigation_action.get_request().get_uri ());
            return null;
        });

        decide_policy.connect ((decision, type) => {
            switch (type) {
                case WebKit.PolicyDecisionType.NEW_WINDOW_ACTION:
                    if (decision is WebKit.ResponsePolicyDecision) {
                        launch_browser ((decision as WebKit.ResponsePolicyDecision).request.get_uri ());
                    }
                break;
                case WebKit.PolicyDecisionType.RESPONSE:
                    if (decision is WebKit.ResponsePolicyDecision) {
                        var policy = (WebKit.ResponsePolicyDecision) decision;
                        launch_browser (policy.request.get_uri ());
                        return false;
                    }
                break;
            }

            return true;
        });

        load_changed.connect ((event) => {
            if (event == WebKit.LoadEvent.FINISHED) {
                var rectangle = get_window_properties ().get_geometry ();
                set_size_request (rectangle.width, rectangle.height);
            }
        });
    }

    private void launch_browser (string url) {
        if (!url.contains ("/embed/")) {
            try {
                AppInfo.launch_default_for_uri (url, null);
            } catch (Error e) {
                warning ("No app to handle urls: %s", e.message);
            }
            stop_loading ();
        }
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
                                                        //Extra Footnote + Autolink + ``` code + Extra def lists + keep style + LaTeX
        var mkd = new Markdown.Document.from_string (processed_mk.data, 0x00200000 + 0x00004000 + 0x02000000 + 0x01000000 + 0x00400000 + 0x40000000);
        mkd.compile (0x00200000 + 0x00004000 + 0x02000000 + 0x01000000 + 0x00400000 + 0x40000000);

        string result;
        mkd.document (out result);

        string html = "<!doctype html><meta charset=utf-8><head>";
        html += "<style>"+ CSS +"</style>";
        html += "</head><body><div class=\"markdown-body\">";
        html += process_plugins (result);
        html += "</div></body></html>";

        return html;
    }

    private string process_plugins (string raw_mk) {
        var lines = raw_mk.split ("\n");
        string build = "";
        foreach (var line in lines) {
            bool found = false;
            foreach (var plugin in PluginManager.get_instance ().get_plugs ()) {
                if (plugin.has_match (line)) {
                    build = build + plugin.convert (line) + "\n";
                    found = true;
                    break;
                }
            }

            if (!found) {
                build = build + line + "\n";
            }
        }

        return build;
    }
}
