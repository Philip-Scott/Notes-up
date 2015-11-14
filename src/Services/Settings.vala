public class ENotes.Services.Settings : Granite.Services.Settings {
    public int pos_x { get; set; }
    public int pos_y { get; set; }
    public int window_width { get; set; }
    public int window_height { get; set; }
    public int panel_size { get; set; }
    public int mode { get; set; }
    public string last_folder { get; set; }
    public string page_path { get; set; }
	public string page_name { get; set; }

    public Settings () {
        base ("org.felipe.enotes");
    }
}
