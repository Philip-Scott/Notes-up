#Notes Up
##Your New Notebook

As a computer engineer, I've been writing my school notes using just a text editor, and having to manage all my files and keep everything organized. Well, not anymore! **Notes Up** is a notes manager written for elementary OS. With it, you'll be able to write beautiful notes fast and easy using the markdown format.

###It's Features Include:

- Multiple notebook support
- Easy-to-use markdown editor
- Exporting to PDF
- And more to come!

![screenshot](https://github.com/Philip-Scott/Notes-up/blob/master/Screenshot.png?raw=true)

## Now in 1.3!

- Notes-Up is now faster than ever! It now uses a database as its backend and saves the preview for quickly loading
- You can now rename your bookmarks! Double-click on them to rename them
- Plugins! There are currently 2 plugins installed by default, and with many more to come in the future.
	- **Color**: You can now easily change the text color! Select it and click the new color button right from the toolbar or by typing ` <color rgb(164,0,0) [your text here]> `
	- **Youtube**: By typing `<youtube [your video URL]>`, you can now embed youtube videos right into your notes!
- Fixed: Sometimes the app would show a raw html document. It shouldn't do that anymore!
- Fixed: Editing and adding a notebook used to restart the whole sidebar, it also doesn't do that anymore!
- Fixed: Links are now passed to your web browser.

You can also view the full [changelog here](changelog.md)

## Donations
If you liked _Notes-up_, and would like to support it's development of this app and more, consider [buying me a coffee](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=WYD9ZJK6ZFUDQ) :) 

##Installation:
If you are using elementary OS **Loki**, in order to add a PPA you might need to first run

	sudo apt-get install software-properties-common

PPA: _ppa:philip.scott/notes-up_

	sudo add-apt-repository ppa:philip.scott/notes-up
	sudo apt-get update
	sudo apt-get install notes-up
	
If you were using the previous version of Notes-up, **you will need to add this new PPA**. This version changes how files are saved on your computer, so it won't be given automatically to the previous users. No worries though, your old files will be imported when you first run the app!

##How To Build
For advanced users!

	git clone https://github.com/Philip-Scott/Notes-up
	cd Notes-up
	mkdir build && cd build 
	cmake -DCMAKE_INSTALL_PREFIX=/usr ../
	make
