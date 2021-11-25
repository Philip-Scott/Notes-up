<div>
  <h1 align="center">Notes-Up</h1>
  <h3 align="center">Write beautiful notes fast and easy using Markdown</h3>
</div>

<br/>

<p align="center">
  <a href="https://appcenter.elementary.io/com.github.philip_scott.notes-up">
    <img src="https://appcenter.elementary.io/badge.svg" alt="Get it on AppCenter">
  </a>
</p>

<br/>

<p align="center">
    <img src="Screenshot.png" alt="Screenshot">
</p>

<h2> </h2>

As a Systems Engineer, I was writing my notes using just a text editor, and having to manage all my files and keep everything organized. Well, not anymore! **Notes Up** is a notes manager written for elementary OS. With it, you'll be able to write beautiful notes fast and easy using the markdown format.

### It's Features Include:

- Multiple notebook support
- Easy-to-use markdown editor
- Tags, to quickly find and organize your notes
- Exporting to PDF and Markdown
- Built-In markdown cheat-sheet
- Special plugins such as syntax highlight, links to other pages, inserting images, and setting font color!
- Spell check
- Beautiful app themes
- And more to come!

## Installation:
[![Get it on AppCenter](https://appcenter.elementary.io/badge.svg)](https://appcenter.elementary.io/com.github.philip_scott.notes-up)

On elementary OS? Hit the button to get Notes-Up!

#### Not on elementary?
Notes-Up is made for elementary OS, but has been built and made available elsewhere by community members. These builds may have modifications or changes and are not provided or supported by me.

Notes-Up is available for [openSUSE](https://software.opensuse.org/package/notes-up), and [Arch Linux](https://aur.archlinux.org/packages/?O=0&K=notes-up).

You can also install Notes-Up from a PPA. But be aware that your results may vary and it may require the elementary OS PPA as it uses a newer version of the granite library.

PPA: _ppa:philip.scott/notes-up_

```bash
sudo add-apt-repository ppa:philip.scott/notes-up
# sudo add-apt-repository ppa:elementary-os/stable
sudo apt-get update
sudo apt-get install com.github.philip-scott.notes-up
```

## How To Build
For advanced users!

```bash
git clone https://github.com/Philip-Scott/Notes-up
cd Notes-up

flatpak-builder build com.github.philip_scott.notes-up.yml --user --install --force-clean
flatpak run com.github.philip_scott.notes-up
```