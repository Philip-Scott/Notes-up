public class ENotes.SidebarItem : Gtk.Button {
    public Gtk.Label label { get; private set;}
    public Gtk.Box box { get; private set;}
 
    construct {
        //this.hexpand = true;
        this.can_focus = false;
        
        box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        label = new Gtk.Label ("");
            
        box.add (label);
        this.add (box);
    }
}
