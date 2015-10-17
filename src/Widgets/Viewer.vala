public class ENotes.Viewer : WebKit.WebView {
    private const string pre = "<!DOCTYPE html><html> <head> <style>";
    private const string postCSS = "</style> </head>";
    private const string post = "</body></html>";

    private bool bold_state = true;
    private bool italics_state = true;
    private bool code_state = true;

    public Viewer () {

    }

    public void load_string (string page_content) {
        if (headerbar.get_mode () == 1) return;

        load_html (pre + CSS + postCSS + convert(page_content) + post, null);
    }

    private string convert (string raw_content) {
        var lines = raw_content.split ("\n", -1);
        StringBuilder builder = new StringBuilder ();

        string final = "";
        foreach (string line in lines) {
            while (line.contains ("  ")) { //Line cleanup
                line = line.replace ("  ", " ");
            }

            while (line.contains ("----")) { //Line cleanup
                line = line.replace ("----", "---");
            }

            if (line.contains ("	")) {
                line = line.replace ("	", "&nbsp;&nbsp;&nbsp;&nbsp;");
            }
            
            if (line.contains ("```")) {
                line = apply_code (line);
                if (code_state) {

                    line = line + "<br>";
                }
            }

            if (line == "") {
                line = line + "<br><br>\n";

            } else if (line[0:6] == ("######")) {
                builder.assign (line);
                builder.erase (0,6);
                line = "<h6>" + builder.str + "</h6\n>";

            } else if (line[0:5] == ("#####")) {
                builder.assign (line);
                builder.erase (0,5);
                line = "<h5>" + builder.str + "</h5\n>";

            } else if (line[0:4] == ("####")) {
                builder.assign (line);
                builder.erase (0,4);
                line = "<h4>" + builder.str + "</h4\n>";

            } else if (line[0:3] == ("###")) {
                builder.assign (line);
                builder.erase (0,3);
                line = "<h3>" + builder.str + "</h3\n>";

            } else if (line[0:2] == ("##")) {
                builder.assign (line);
                builder.erase (0,2);
                line = "<h2>" + builder.str + "</h2\n>";

            } else if (line[0:1] == ("#")) {
                builder.assign (line);
                builder.erase (0,1);
                line = "<h1>" + builder.str + "</h1\n>";

            } else if (line[0:3] == ("---")) {
                builder.assign (line);
                builder.erase (0,3);
                line = "<hr>";

            } else {
                //line = "<p>" + line + "</p>";
            }

            if (line.contains ("**")) {
                line = apply_bold (line);  //word <b> word </b> word
            }

            if (line.contains ("_")) {
                line = apply_italics (line); //word <i> word </i> word
            }

            if (!code_state) {
                line = line + "<br>";
            }



            final = final + line + "\n";
        }

        bold_state = true;
        italics_state = true;
        code_state = true;
        return final;
    }

    private string apply_code (string line_) {
        int chars = line_.length;
        string line = line_ + "    ";
        StringBuilder final = new StringBuilder ();
        for (int i = 0; i < chars; i++) {
            if (line[i:i + 3] == "```") {
                if (code_state) {
                    code_state = false;
                    final.append ("<code>");
                } else {
                    code_state = true;
                    final.append ("</code>");
                }
                i = i + 3;
            }  else {
                final.append (line[i:i+1]);
            }
        }

        return final.str;
    }

    private string apply_italics (string line_) {
        int chars = line_.length;
        string line = line_ + "   ";
        StringBuilder final = new StringBuilder ();
        for (int i = 0; i < chars; i++) {
            if (line[i:i + 1] == "_") {  // rrr ** ffffa ** fdfd
                if (italics_state) {
                    italics_state = false;
                    final.append ("<i>");
                } else {
                    italics_state = true;
                    final.append ("</i>");
                }

            }  else {
                final.append (line[i:i+1]);
            }
        }

        return final.str;
    }

    private string apply_bold (string line_) {
        int chars = line_.length;
        string line = line_ + "   ";
        StringBuilder final = new StringBuilder ();
        for (int i = 0; i < chars; i++) {
            if (line[i:i + 2] == "**") {  // rrr ** ffffa ** fdfd
                if (bold_state) {
                    bold_state = false;
                    final.append ("<b>");
                } else {
                    bold_state = true;
                    final.append ("</b>");
                }
                i++;
            }  else {
                final.append (line[i:i+1]);
            }
        }


        return final.str;
    }

private const string CSS = """
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
    margin: 1.5em 1em 0.25em;
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

h2 {
    font-size: 2rem;
    font-weight: 600;
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
}""";


}
