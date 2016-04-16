
public class ENotes.ViewEditStack : Gtk.Overlay {
    public signal void page_set (ENotes.Page page);

    private ENotes.Page current_page;
    private Gtk.Stack stack;

    public ViewEditStack () {
        stack = new Gtk.Stack ();

        viewer = new ENotes.Viewer ();
        editor = new ENotes.Editor ();
        stack.add_named (editor, "editor");
        stack.add_named (viewer, "viewer");

        this.add (stack);
        this.show_all ();
    }

    public void set_page (ENotes.Page page) {
        current_page = page;
        editor.set_page (page);

        bookmark_button.set_page (page);

        page_set (page);
    }
    public ENotes.Page get_page () {
        return current_page;
    }

    public void show_edit () {
        stack.set_visible_child_name ("editor");
        //bookmark_button.set_toolbar_mode (true);
    }
    public void show_view () {
        stack.set_visible_child_name ("viewer");
        //bookmark_button.set_toolbar_mode (false);
    }

}
