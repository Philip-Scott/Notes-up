#Notes Up
##Your New Notebook

As a computer engineer, I've been writing my school notes using just a text editor, and having to manage all my files and keep everything organized. Well, not anymore! **Notes Up** is a notes manager written for elementary OS. With it, you'll be able to write beautiful notes fast and easy using the markdown format.

###It's Features Include:

- Multiple notebook support
- Easy-to-use markdown editor
- Exporting to PDF
- And more to come!

![screenshot](https://github.com/Philip-Scott/Notes-up/blob/master/Screenshot.png?raw=true)

## Major changes in 1.2:
- In-app trash for deleted pages: Pages or notebooks you delete will first be sent to a trash on the sidebar. Files here will be deleted when the app closes, but it should give you an extra chance to save them!
- 2 new Stylesheets: Air and Modest by [John Otander](https://github.com/markdowncss), you can also now select and modify the stylesheet per-notebook!
- Contractor integration: You can now email and send via bluetooth directly from the app, as well as any other action apps give via the Contractor API. 
- For you Keyboard lovers or mouse haters, the edit view now has keyboard shortcuts for bold, italics and strikethrough. Don't know the keyboard shortcuts? Well you can now see them by hovering over the buttons.
- You can now add bookmarks from the UI.

You can also view the full [changelog here](changelog.md)

##Installation:
If you are using elementary OS **Loki**, in order to add a PPA you might need to first run

	sudo apt-get install software-properties-common

PPA: _ppa:philip.scott/projects_

	sudo add-apt-repository ppa:philip.scott/projects
	sudo apt-get update
	sudo apt-get install notes-up

## Donations
If you liked _Notes-up_, and would like to support it's development of this app and more, a [little tip](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=WYD9ZJK6ZFUDQ) would be much appreciated :) 

##How To Build
For advanced users!

	git clone https://github.com/Philip-Scott/Notes-up
	cd Notes-up
	mkdir build && cd build 
	cmake -DCMAKE_INSTALL_PREFIX=/usr ../
	make
	
### Future plans! 
I'm actually very happy with how this app is turning up :) It just started as a small project for my college class, so the support it's being getting is pretty moving! Version 1.2 is is just the begining! For 1.3 I'd really like to add more things such as a way to move notes arround in the app and a Plugin API that would bring extra (non-standard) features such as easly inserting Web Pages, making simple graphs, LATeX support and who knows what else! 

Thank you all for your love and support!

