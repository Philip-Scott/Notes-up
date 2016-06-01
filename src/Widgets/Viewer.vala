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
    private File temp_file;

    public static Viewer get_instance () {
        if (instance == null) {
            instance = new Viewer ();
        }

        return instance;
    }

    private Viewer () {
        load_css ();

        string file = "/tmp/notes-up-render-" + GLib.Environment.get_user_name ();
        temp_file = File.new_for_path (file);

        connect_signals ();
    }

    public void load_css () {
        CSS = DEFAULT_CSS + ENotes.settings.render_stylesheet;
    }

    public void load_string (string page_content, bool force_load = false) {
        if (Headerbar.get_instance ().get_mode () == 1 && !force_load) return;

        string html;
        process_frontmatter (page_content, out html);

        try {
            FileManager.write_file(temp_file, process (html), true);
            load_uri (temp_file.get_uri ());
        } catch (Error e) {
            load_html ("<h1>Sorry....</h1> <h2>Loading your file failed :(</h2> <br>", null);
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

private const string DEFAULT_CSS = """
html,
body {
    margin: 1em;

    background-color: #fff;

    font-size: 16px;
    font-family: "Open Sans", "Droid Sans", Helvetica, sans-serif;
    font-weight: 400;
    color: #333;
}

body * {
    max-width: 800px;
    margin-left: auto;
    margin-right: auto;
}

/**************
* Text Styles *
**************/

a{
    color: #08c;
    text-decoration: none;
}

a:focus{
    outline: none;
    text-decoration: underline;
}

h1,
h2,
h3,
h4,
h5,
h6{
    margin: 1.5em 0 0.25em;
    padding: 0;
    text-align: left;
}

h4,
h5,
h6{
    margin-top: 2em;
    margin-bottom: 0;
}

h1{
    margin-top: 0;

    font-family: "Raleway", "Open Sans", "Droid Sans", Helvetica, sans-serif;
    font-size: 3rem;
    font-weight: 200;
    text-align: center;
}

h1 + h1 {
    color: #666;
    margin: 0em 0 0em;
    font-size: 2.5rem;
}

h2 {
    font-size: 2rem;
    font-weight: 600;
}

h2 + h2 {
    font-size: 1.50rem;
    margin: 0em 0 0.25em;
}

h3{
    font-size: 1.5rem;
    font-weight: 600;

    opacity: 0.8;
}

h4{
    font-size: 1.125rem;
    font-weight: 300;
}

h5{
    font-size: 1rem;
    font-weight: 600;
}

p {
    text-align: left;
}

/*******
* Code *
*******/

code{
    display: inline-block;
    padding: 0 0.25em;

    background-color: #f3f3f3;

    border: 1px solid #ddd;
    border-radius: 3px;

    font-family: "Droid Sans Mono","DejaVu Mono",mono;
    font-weight: normal;
    color: #403a36;
}

pre code{
    display: block;
    margin: 1em auto;
    overflow-x: scroll;
}

/***********
* Keyboard *
***********/

kbd{
    padding: 2px 4px;
    margin: 3px;

    background-color: #eee;
    background-image: linear-gradient(to bottom, #eee, #fff);

    border: 1px solid #a5a5a5;
    border-radius: 3px;

    box-shadow: inset 0 1px 0 0 #fff,
        inset 0 -2px 0px 0 #d9d9d9,
        0 1px 2px 0 rgba(0,0,0,0.1);

    font-family: inherit;
    font-size: inherit;
    font-weight: 500;
    color: #4d4d4d;
}

/*********
* Images *
*********/

img{
    display: block;
    margin: 1em auto;
    max-width: 100%;
}

/******************
* Horizontal Rule *
******************/

hr{
    margin: 2em;
    height: 1px;

    background-image: -webkit-linear-gradient(left, rgba(0,0,0,0), rgba(0,0,0,0.5), rgba(0,0,0,0));

    border: 0;
}


/********
* Table *
********/

table {
    border-collapse: collapse;
}

th, td {
    padding: 8px;
}

tr:nth-child(even){background-color: #fafafa}


blockquote {
    border-left: 4px solid #dddddd;
    padding: 0 15px;
    color: #777777;
}

blockquote > :first-child {
    margin-top: 0;
}

blockquote > :last-child {
    margin-bottom: 0;
}
""";
}
