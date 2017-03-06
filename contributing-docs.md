---
layout: default
---

# Contributing to the documentation

The documentation is built on top of Github pages. Github pages is a static site
generator that is powered by the [Jekyll static web site
generator](http://jekyllrb.com/). You author content using
[Markdown](https://daringfireball.net/projects/markdown/syntax), so you can use
any Markdown editor that you want to create your content ([Visual Studio
Code](https://code.visualstudio.com/) is fantastic, and is what I use these
days). Also, you have the flexibility of installing Jekyll locally on your PC so
that you can preview your changes before you commit / submit a PR to the
repository.

## Installing Jekyll locally on your PC

This is a very painless process because of [Chocolatey, the Windows Package
Manager](https://chocolatey.org/). To install Chocolatey, open an elevated
Powershell prompt and run:

```powershell
iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
```

Once you've got Chocolatey installed, you can install Ruby using:

```powershell
choco install ruby -y
```

Now you need to exit your Powershell prompt and start another one so you can
pickup the new path that contains your local Ruby installation. Now you can use
the Ruby package manager, gem, to install jekyll:

```powershell
gem install jekyll
```

## Cloning and making changes to the docs

The first step is cloning the Github repo:

```powershell
git clone https://github.com/Microsoft/RTVS-docs.git
```

Next, you need to checkout the gh-pages branch, since that's the branch where
the docs live; they don't live in master.

```powershell
git checkout gh-pages
```

## Editing the documents

You can use any editor to write markdown documents. However, beware that Windows
Notepad will insert a BOM that will cause the Jekyll document generator to
crash. _So don't use Notepad :)_

I've been successful using [vim](http://www.vim.org/) and these plugins which
you can install by adding to your .vimrc file:

```vim
Plugin 'godlygeek/tabular'       " markdown
Plugin 'plasticboy/vim-markdown' " markdown
```

Note that these plugins use the popular
[Vundle](https://github.com/VundleVim/Vundle.vim) git package manager which you
can install by navigating to your home directory and typing:

```powershell
git clone https://github.com/VundleVim/Vundle.vim.git .vim\bundle\Vundle.vim
```

If WYSIWYG with live preview is more your thing, I highly recommend [Visual
Studio Code](https://code.visualstudio.com/). There is a live, side-by-side
preview window that updates as you edit your Markdown. Also, there is an
excellent vim key binding extension if that's your thing as well.
