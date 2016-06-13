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
    public static string[] STYLES = {_("Default"), ("elementary"), ("Splendor"), "Modest"};

    private static Viewer? instance = null;

    public string CSS;
    private string previous_path = "";
    private Page previous_page;
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
            case "Splendor": CSS = SPLENDOR + ENotes.settings.render_stylesheet; break;
            case "elementary": CSS = DEFAULT_CSS + ENotes.settings.render_stylesheet; break;
            case "Modest": CSS = MODEST + ENotes.settings.render_stylesheet; break;
            default:
                if (trying_global == false) {
                    set_styleshet (ENotes.settings.stylesheet, true);
                } else {
                    CSS = DEFAULT_CSS + ENotes.settings.render_stylesheet;
                }
                break;
        }
    }

    public new void reload () {
        load_css (previous_page, true);
        load_page (previous_page);
    }

    public void load_page (Page page, bool force_load = false) {
        if (Headerbar.get_instance ().get_mode () == 1 && !force_load) return;
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
//-------------------------------------------------------------------------------------------------------------------------------------
private const string SPLENDOR = """
body {
  line-height: 1.85;
}

p,
.splendor-p {
  font-size: 1rem;
  margin-bottom: 1.3rem;
}

h1,
.splendor-h1,
h2,
.splendor-h2,
h3,
.splendor-h3,
h4,
.splendor-h4 {
  margin: 1.414rem 0 .5rem;
  font-weight: inherit;
  line-height: 1.42;
}

h1,
.splendor-h1 {
  margin-top: 0;
  font-size: 3rem;
}

h2,
.splendor-h2 {
  font-size: 2.827rem;
}

h3,
.splendor-h3 {
  font-size: 1.999rem;
}

h4,
.splendor-h4 {
  font-size: 1.414rem;
}

h5,
.splendor-h5 {
  font-size: 1.121rem;
}

h6,
.splendor-h6 {
  font-size: .88rem;
}

small,
.splendor-small {
  font-size: .707em;
}

/* https://github.com/mrmrs/fluidity */

img,
canvas,
iframe,
video,
svg,
select,
textarea {
  max-width: 100%;
}

@import url(http://fonts.googleapis.com/css?family=Merriweather:300italic,300);

html {
  font-size: 18px;
  max-width: 100%;
}

body {
  color: #444;
  font-family: 'Merriweather', Georgia, serif;
  margin: 0;
  max-width: 100%;
}

/* === A bit of a gross hack so we can have bleeding divs/blockquotes. */

p,
*:not(div):not(img):not(body):not(html):not(li):not(blockquote):not(p) {
  margin: 1rem auto 1rem;
  max-width: 36rem;
  padding: .25rem;
}

div {
  width: 100%;
}

div img {
  width: 100%;
}

blockquote p {
  font-size: 1.5rem;
  font-style: italic;
  margin: 1rem auto 1rem;
  max-width: 48rem;
}

li {
  margin-left: 2rem;
}

/* Counteract the specificity of the gross *:not() chain. */

h1 {
  padding: 1rem 0 !important;
}

/*  === End gross hack */

p {
  color: #555;
  height: auto;
  line-height: 1.45;
}

pre,
code {
  font-family: Menlo, Monaco, "Courier New", monospace;
}

pre {
  background-color: #fafafa;
  font-size: .8rem;
  overflow-x: scroll;
  padding: 1.125em;
}

a,
a:visited {
  color: #3498db;
}

a:hover,
a:focus,
a:active {
  color: #2980b9;
}

""";

private const string MODEST = """
pre,
code {
  font-family: Menlo, Monaco, "Courier New", monospace;
}

pre {
  padding: .5rem;
  line-height: 1.25;
  overflow-x: scroll;
}

a,
a:visited {
  color: #3498db;
}

a:hover,
a:focus,
a:active {
  color: #2980b9;
}

.modest-no-decoration {
  text-decoration: none;
}

html {
  font-size: 12px;
}

body {
  line-height: 1.85;
}

p,
.modest-p {
  font-size: 1rem;
  margin-bottom: 1.3rem;
}

h1,
.modest-h1,
h2,
.modest-h2,
h3,
.modest-h3,
h4,
.modest-h4 {
  margin: 1.414rem 0 .5rem;
  font-weight: inherit;
  line-height: 1.42;
}

h1,
.modest-h1 {
  margin-top: 0;
  font-size: 3rem;
}

h2,
.modest-h2 {
  font-size: 2rem;
}

h3,
.modest-h3 {
  font-size: 2rem;
}

h4,
.modest-h4 {
  font-size: 1.4rem;
}

h5,
.modest-h5 {
  font-size: 1.121rem;
}

h6,
.modest-h6 {
  font-size: .88rem;
}

small,
.modest-small {
  font-size: .707em;
}

/* https://github.com/mrmrs/fluidity */

img,
canvas,
iframe,
video,
svg,
select,
textarea {
  max-width: 100%;
}

@import url(http://fonts.googleapis.com/css?family=Arimo:700,700italic);

html {
  font-size: 18px;
  max-width: 100%;
}

body {
  color: #222;
  font-family: 'Open Sans', sans-serif;
  font-weight: 300;
  margin: 0 auto;
  max-width: 48rem;
  line-height: 1.45;
  padding: .25rem;
}

h1,
h2,
h3,
h4,
h5,
h6 {
  font-family: Arimo, Helvetica, sans-serif;
}

h1 {
  border-bottom: 2px solid #fafafa;
  margin-bottom: 1.15rem;
  padding-bottom: .5rem;
  text-align: center;
}

blockquote {
  border-left: 8px solid #fafafa;
  padding: 1rem;
}

pre,
code {
  background-color: #fafafa;
} """;
}
