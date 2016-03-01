#Notes Up
##Your New Notebook

As a computer engineer, I've been writing my school notes using just a text editor, and having to manage all my files and keep everything organized. Well, not anymore! **Notes Up** is a notes manager written for elementary OS. With it, you'll be able to write beautiful notes fast and easy using the markdown format.

###It's Features Include:

- Multiple notebook support
- Easy-to-use markdown editor
- Exporting to PDF
- And more to come!

![screenshot](https://github.com/Philip-Scott/Notes-up/blob/master/Screenshot.png?raw=true)

##Installation:
[ppa:philip.scott/projects](https://launchpad.net/~philip.scott/+archive/ubuntu/projects/)

	sudo add-apt-repository ppa:philip.scott/projects
	sudo apt-get update
	sudo apt-get install notes-up

##How To Build
	git clone https://github.com/Philip-Scott/Notes-up
	cd Notes-up
	mkdir build && cd build 
	cmake -DCMAKE_INSTALL_PREFIX=/usr ../
	make
