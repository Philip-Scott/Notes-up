#Notes Up
##Your New Notebook

As a computer engineer, I've been writing my school notes using just a text editor, and having to manage all my files and keep everything organized. Well, not anymore! **Notes Up** is a notes manager written for elementary OS. With it, you'll be able to write beautiful notes fast and easy using the markdown format.

###It's Features Include:

- Multiple notebook support
- Easy-to-use markdown editor
- Exporting to PDF
- And more to come!

![screenshot](https://github.com/Philip-Scott/Notes-up/blob/master/Screenshot.png?raw=true)

###1.1 Release Changelog:

- You can now search for content in the current notebook! Be gone the days where you had to manually search through your notes!
- Deletion & creation of sub-notebooks or "Sections" is now possible!
- The pages list has been taken to the stylist. It is now 89% better looking!
- Local images are now being loaded properly. Actually, they are just being loaded now.... they didn't before.
- CSS experts should be happy to know that you can now edit the notebook's stylesheet right from the preferences dialog! For non-CSS experts wanting a new look, I recommend [googling some stylesheets](http://www.google.com.mx/search?rls=x86_64&q=markdown+stylesheets)
- Fixed: Ugly bug were you sometimes couldn't export to pdf. That should be squashed now!

##Installation:
	sudo add-apt-repository ppa:philip.scott/projects
	sudo apt-get update
	sudo apt-get install notes-up

##How To Build
	git clone https://github.com/Philip-Scott/Notes-up
	cd Notes-up
	mkdir build && cd build 
	cmake -DCMAKE_INSTALL_PREFIX=/usr ../
	make
