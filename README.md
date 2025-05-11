[![Build Status](https://github.com/vim/vim-appimage/workflows/Release%20AppImage/badge.svg)](https://github.com/vim/vim-appimage/actions?query=workflow%3A%22Release+AppImage%22)

# Vim AppImage Repository

This is a project for building a 64bit Gvim AppImage from the latest Vim snapshots.
AppImage is a form of cross-distribution packaging format that can be run
everywhere by simply downloading the image and starting it. For more
information about the package format see here: [AppImage](https://appimage.org).

The image is based on Ubuntu ~~20.04 LTS focal~~ 22.04 LTS jammy (since commit
1bfa21bf90229c2f5ef8ec2f72bb5a074caa0949 because Github retired the Ubuntu
20.04 images in April 2025)

The Appimage most likely won't work on older distributions. If you require a
Vim appimage, that runs on older distributions, you can download the last
Ubuntu 18.04 bionic based installation [v9.0.1413][v9.0.1413] and the last
Ubuntu 20.04 focal based installation [v9.1.1301][v9.1.1301]

[Download][Download] and execute the most recent `GVim-*.AppImage` file to run GVim.

If you want a terminal Vim, just create a symbolic link with a name starting with "vim". Like:
```
ln -s GVim-*.AppImage vim.appimage
```

Then start `vim.appimage` to get a terminal Vim.

The vim / gvim AppImage's are built with Vim interfaces for Perl, Python3, Ruby
and Lua. See the release notes for usage and details.

See: https://github.com/vim/vim

# License

The Vim license applies (see [:h
license](http://vimhelp.appspot.com/uganda.txt.html#license)) to all the build
scripts in this repository. Note, that Vim is included as a submodule and comes
with its own license (although is also released under the Vim license).

[v9.0.1413]: https://github.com/vim/vim-appimage/releases/tag/v9.0.1413
[v9.1.1301]: https://github.com/vim/vim-appimage/releases/tag/v9.1.1301
[Downloads]: https://github.com/vim/vim-appimage/releases
