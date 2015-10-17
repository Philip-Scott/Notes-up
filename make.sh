#Create .Desktop file
echo "[Desktop Entry]" > /home/$(whoami)/.local/share/applications/Notes.desktop
echo "Encoding=UTF-8" >> /home/$(whoami)/.local/share/applications/Notes.desktop
echo "Name=Notes" >> /home/$(whoami)/.local/share/applications/Notes.desktop
echo "Comment=Lights On/Lights Off" >> /home/$(whoami)/.local/share/applications/Notes.desktop
echo "Exec=$(pwd)/Main" >> /home/$(whoami)/.local/share/applications/Notes.desktop
#echo "Icon=$(pwd)/Pixsim.svg" >> /home/$(whoami)/.local/share/applications/Notes.desktop
echo "Terminal=false" >> /home/$(whoami)/.local/share/applications/Notes.desktop
echo "Type=Application" >> /home/$(whoami)/.local/share/applications/Notes.desktop
echo "StartupNotify=true" >> /home/$(whoami)/.local/share/applications/Notes.desktop
echo "Categories=Office" >> /home/$(whoami)/.local/share/applications/Notes.desktop

valac-0.28 --pkg gtk+-3.0 --pkg webkit2gtk-3.0 --pkg granite --pkg gtksourceview-3.0 --thread --target-glib 2.32 src/Main.vala src/Application.vala src/Widgets/Window.vala src/Widgets/Headerbar.vala src/Widgets/Editor.vala src/Widgets/Sidebar.vala src/Widgets/PagesList.vala src/Widgets/Viewer.vala src/Widgets/SidebarItem.vala src/Widgets/NewNotebookDialog.vala src/Widgets/NotebookItem.vala src/Widgets/PageItem.vala src/Services/FileManager.vala && ./Main



