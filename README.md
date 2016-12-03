[![Build Status](https://travis-ci.org/chrisbra/vim-appimage.svg?branch=master)](https://travis-ci.org/chrisbra/vim-appimage)

# Vim Appimage Repository

This is a project for building a 64bit Gvim Appimage from the latest Vim snapshots.
Appimage is a form of cross-distribution packaging format that can be run
everywhere by simpling downloading the image and starting it. For more
information about the package format see here: [AppImage](https://appimage.org).

The image is based on Ubuntu 12.04 LTS precise. It most likely won't work on older distributions.

[Download](https://github.com/vim/vim-win32-installer/releases) and execute the
most recent `gvim-8.0.X_*.appimage` file to install Vim.

If you need a dynamic interface to Perl, Python2, Python3, Ruby or Lua make
sure your system provides the needed dynamic libraries (e.g. libperlX,
libpython2.7 libpython3X liblua5.1 and libruby1.9X) as those are **not**
distributed together with the image to not make the image too large.

However, Vim will work without those libraries, but some Plugin might need those additional dependency.
(e.g. Gundo needs a working Pyhton2 installation, Command-T needs a working Ruby
installation and Neocomplete needs a working Lua installation). This means,
those interpreters have to be installed in addition to Vim. Without it Vim
won't be able to use that feature!

See: https://github.com/vim/vim
