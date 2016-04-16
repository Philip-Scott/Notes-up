public interface ENotes.Plugin : Object {
	public abstract void registered (PluginLoader loader);
	public abstract void activated ();
	public abstract void deactivated ();

	public abstract string get_desctiption (); //Description of the plugin
	public abstract string get_name (); //Plugin name

	public abstract PatternSpec get_pattern (); //What the module looks for in order to convert

	public abstract string convert (string line); //Once the viewer finds the key, it will call this function
}
