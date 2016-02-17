---
layout: default
---

# Contributing to the documentation

The documentation is built on top of Github pages. Github pages is a static site
generator that is powered by the [Jekyll static web site
generator](http://jekyllrb.com/). You author content using Markdown, so you can
use any Markdown editor that you want to create your content. Also, you have the
flexibility of installing Jekyll locally on your PC so that you can preview your
changes before you commit / submit a PR to the repository.

## Installing Jekyll locally on your PC

This is a very painless process because of [Chocolatey, the Windows Package
Manager](https://chocolatey.org/). To install Chocolatey, open an elevated
Powershell prompt and run:

{% highlight powershell %}
iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
{% endhighlight %}

Once you've got Chocolatey installed, you can install Ruby using:

{% highlight powershell %}
choco install ruby -y
{% endhighlight %}

Now you need to exit your Powershell prompt and start another one so you can
pickup the new path that contains your local Ruby installation. Now you can use
the Ruby package manager, gem, to install jekyll:

{% highlight powershell %}
gem install jekyll
{% endhighlight %}

## Cloning and making changes to the docs

The first step is cloning the Github repo:

{% highlight powershell %}
git clone https://github.com/Microsoft/RTVS-docs.git
{% endhighlight %}

Next, you need to checkout the gh-pages branch, since that's the branch where
the docs live; they don't live in master.

{% highlight powershell %}
git checkout gh-pages
{% endhighlight %}

## Editing the documents

You can use any editor to write markdown documents. However, Windows Notepad
will insert a BOM that will cause the Jekyll document generator to crash. 

I've been successful using [vim](http://www.vim.org/) and these plugins which
you can install by adding to your .vimrc file:

{% highlight vim %}
Plugin 'godlygeek/tabular'       " markdown
Plugin 'plasticboy/vim-markdown' " markdown
{% endhighlight %}

Note that these plugins use the popular [Vundle]() git package manager which you
can install by navigating to your home directory and typing:

{% highlight powershell %}
git clone https://github.com/VundleVim/Vundle.vim.git .vim\bundle\Vundle.vim
{% endhighlight %}

If WYSIWYG with live preview is more your thing, you can use
[Haroopad](http://pad.haroopress.com/).


