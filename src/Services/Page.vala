
public class ENotes.Page : Object {//, Gee.Comparable<G> {
    public signal void saved_file ();
    public signal void destroy ();

	public string name  { public get; private set; }
	public string subtitle { public get; private set; }
	public string full_path { public get; private set; } //File's location + full name
	public string path { public get; private set; } //This file's location
	public int date { public get; private set; }
	public int ID = -1;
	public bool new_page = false;

	private string page_data;
	private bool changed = true;

	private File file { public get; private set; }

	public Page (string path) {
		full_path = path;
		file = File.new_for_path (full_path);

		if (!file.query_exists ()) {
			new_page = true;
		}

		var l = full_path.length;
		var ln = l - file.get_basename ().length;

		this.path = full_path.slice(0, ln);
		load_subtitle (get_text ());
	}

	private void load_subtitle (string data) {
        setup ();
        string line[2];
	    var lines = data.split ("\n");

	    if (lines.length > 1) {
	        int n = 0;

	        for(int i = 1; i < lines.length && n < 1; i++) {
	            line[n] = cleanup (lines[i]);
                if (line[n] != "") {
                    n++;
                }
	        }
	    }

        this.subtitle = line[0];

	}

    public string get_text (int to_load = -1) {
        if (new_page) {
        	return "";
        }

        if (!changed) {
            return page_data;
        }

        try {
            var dis = new DataInputStream (this.file.read ());
            size_t size;
            page_data = dis.read_upto ("\0", to_load, out size);
        } catch (Error e) {
            error ("Error loading file: %s", e.message);
        }

        return page_data;
    }

    public void save_file (string data) {
        if (data == "") {
            trash_page ();
            return;
        }

        string file_name = make_filename ();

        try {
		    if (file.query_exists ()) {
                file.delete ();
            }

		    file = File.new_for_path (path + file_name);
		    FileManager.write_file (file, data);

            new_page = false;
        } catch (Error e) {
            stderr.printf ("Error Saving file: %s", e.message);
        }

        changed = true;
        load_subtitle (data);
		this.saved_file ();
    }

    public void trash_page () {
        try {
            file.trash ();
            this.destroy ();
        } catch (Error e) {
            stderr.printf ("Error trashing file: %s", e.message);
        }
    }

    private string cleanup (string line) {
        string output = "";

        if (line.contains ("---")) return "";
        output = line.replace ("#", "").replace ("```", "").replace ("\t", "").replace ("  ", "").replace ("**", "");

        if (output.length < 5) {
            output = "";
        }
    	return output;
    }

    private string make_filename () {
        string file_name = editor.get_text ().split ("\n", 2)[0];
        file_name = file_name.replace ("#", "").replace ("\n", "");

        return ID.to_string () + "§" + file_name;
    }

    private void setup () {
        string t_name = file.get_basename ();
        if (t_name.contains ("§")) {
            var split = t_name.split ("§", 2);
            name = split[1].replace (ENotes.NOTES_DIR, "");
            ID = int.parse (split[0]);
        } else {
            name = t_name;
            ID = -1;
        }

        while (name[0:1] == " ") {
            name = name[1:name.length];
        }
    }
}
