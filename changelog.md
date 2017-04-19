# Changelog: 
## 1.3
- Notes-Up is now faster than ever! It now uses a database as its backend and saves the preview for quickly loading
- You can now rename your bookmarks! Double-click on them to rename them
- Plugins! There are currently 3 plugins installed by default, and with many more to come in the future.
	- **Color**: You can now easily change the text color! Select it and click the new color button right from the toolbar or by typing ` <color rgb(164,0,0) [your text here]> `
	- **Youtube**: By typing `<youtube [your video URL]>`, you can now embed youtube videos right into your notes!
	- **Break**: Exporting to PDF is sometimes a pain... Now by typing `<break>` or clicking it’s new button on the editor you will be able to easily add page breaks on your exports!
- Fixed: Sometimes the app would show a raw html document. It shouldn't do that anymore!
- Fixed: Editing and adding a notebook used to restart the whole sidebar, it also doesn't do that anymore!
- Fixed: Links are now passed to your web browser.

## 1.2.1

- Your notes now autosave every minute if there was a change. No more excuses for lost work +Manuel del Valle ;) 
- Fixed: Notes were sometimes not correctly selected, and re-selecting would override your work... sorry :/ 
- Fixed: New pages started with an empty space because _SOMEONE_ forgot to remove the space used to debug. That's space is no longer there

And that's all! Just three things (They just happened to be some very annoying things)

## 1.2:

- In-app trash for deleted pages: Pages or notebooks you delete will first be sent to a trash on the sidebar. Files here will be deleted when the app closes, but it should give you an extra chance to save them!
- 2 new Stylesheets: Air and Modest by [John Otander](https://github.com/markdowncss), you can also now select and modify the stylesheet per-notebook!
- Contractor integration: You can now email and send via bluetooth directly from the app, as well as any other action apps give via the Contractor API. 
- Double clicking Pages on the Page list will swap between view and edit mode.
- For you Keyboard lovers or mouse haters, the edit view now has keyboard shortcuts for bold, italics and strikethrough. Don't know the keyboard shortcuts? Well you can now see them by hovering over the buttons.
- You can now (finally!) add bookmarks from the UI.
- You can now select multiple pages and delete them with one click! 
- The preview of the pages on the pages list now supports simple markdown such as Bold and Italics. 
- Single clicking on a bookmark will not change notebooks, so you can swap back and forward between your current open notebook and your marks. Double clicking it will bring out the notebook where the page lives, just like before!
- Fixed: The app was crashing if your notebook name or the first line of a note contained `/`. Don't know why you would want to have slashes in your folder names, but now you cannot! 
- Fixed: Sometimes notes would not save if it was newly created. Sorry about that...

## 1.1:

- You can now search for content in the current notebook! Be gone the days where you had to manually search through your notes!
- Deletetion & creatation of sub-notebooks or "Sections" is now possible!
- The pages list has been taken to the stylist. It is now 89% better looking!
- Local images are now being loaded properly. Actually, they are just being loaded now.... they didn't before.
- CSS experts should be happy to know that you can now edit the notebook's stylesheet right from the preferences dialog! For non-CSS experts wanting a new look, I recommend [googling some stylesheets](http://www.google.com.mx/search?rls=x86_64&q=markdown+stylesheets)
- Fixed: Ugly bug were you sometimes couldn't export to pdf. That should be squashed now!

