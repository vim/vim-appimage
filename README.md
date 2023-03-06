[![Build Status](https://github.com/vim/vim-appimage/workflows/Release%20AppImage/badge.svg)](https://github.com/vim/vim-appimage/actions?query=workflow%3A%22Release+AppImage%22)

# Vim AppImage Repository

This is a project for building a 64bit Gvim AppImage from the latest Vim snapshots.
AppImage is a form of cross-distribution packaging format that can be run
everywhere by simply downloading the image and starting it. For more
information about the package format see here: [AppImage](https://appimage.org).

The image is based on Ubuntu ~~18.04 LTS bionic~~ 20.04 LTS bionic (since PR #...)
(because Github retired the Ubuntu 18.04 images in April 2023)

It most likely won't work on older distributions. If you require a Vim appimage,
that runs on older distributions, you can download the latest Ubuntu 18.04 based
installation [here: v9.0.1413](https://github.com/vim/vim-appimage/releases/tag/v9.0.1413)

[Download](https://github.com/vim/vim-appimage/releases) and execute the
most recent `GVim-8.2.X_*.AppImage` file to run GVim.

If you want a terminal Vim, just create a symbolic link with a name starting with "vim". Like:
```
ln -s GVim-v8.2.2965.glibc2.15-x86_64.AppImage vim.appimage
```

Then start `vim.appimage` to get a terminal Vim.

If you need a dynamic interface to Perl, Python2, Python3.8, Ruby or Lua make
sure your system provides the needed dynamic libraries (e.g. libperlX,
libpython2.7 libpython3X liblua5X and librubyX) as those are **not**
distributed together with the image to not make the image too large.

However, Vim will work without those libraries, but some Plugin might need those additional dependency.
This means, those interpreters have to be installed in addition to Vim. Without it Vim
won't be able to use that feature!

See: https://github.com/vim/vim
