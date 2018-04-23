# Vim Cheat.sh

This is a highly configurable vim plugin to browse cheat sheet from
[cheat.sh](https://github.com/chubin/cheat.sh) directly from vim.

There is an asciinema showing how it works :

[![asciicast](https://asciinema.org/a/c6QRIhus7np2OOQzmQ2RNXzRZ.png)](https://asciinema.org/a/c6QRIhus7np2OOQzmQ2RNXzRZ)

## Features

+ Browse existing cheat sheets from cheat.sh directly from vim
+ Get answers on any programming question directly on your vim, just by typing
it then hitting `\CQ` (for Cheat Query).
+ Configure anything

### How to use it

The plugins provides two commands :

    :Cheat
    :CheatReplace

+ These commands takes 0 or 1 argument.
+ If you give no argument, it will send the language of the current buffer and
the visual selection (or the current line in `normal` mode) as a query to
cheat.sh and show the answer in a new buffer (`:Cheat`) or in place of your
question (`:CheatReplace`).
+ If one argument is given, you can complete it from a list of available cheat
sheets or write your own [query](https://github.com/chubin/cheat.sh#search).
+ There are two mappings `<localeader>CQ` and `<localleader>CR` (Cheat Replace)
to run these commands without any arguments.

#### Navigate through answers

Once you have called on of these commands, you can navigate through answers
with `<localleader>CN` (Cheat Next)  `<localleader>CP` (Cheat Previous).

You can also directly use the command :

    :CheatNaviguate delta

Where delta is a numeric value for moving (1, or -1 for next or previous)

#### Notes

+ `<localleader>` is usually '\'.
+ For more info on cheat sheet sources, see
[cheat.sh](https://github.com/chubin/cheat.sh).

## Install

### Vizardry

If you have [Vizardry](https://github.com/dbeniamine/vizardry) installed, you
can run from vim:

    :Invoke -u dbeniamine cheat.sh-vim

### Vundle

Add the following to your Vundle Plugin list (not tested, but should work) :

    Plugin 'dbeniamine/cheat.sh-vim'

### Pathogen install

    git clone https://github.com/dbeniamine/cheat.sh-vim.git ~/.vim/bundle/cheat.sh-vim

### Quick install

    git clone https://github.com/dbeniamine/cheat.sh-vim.git
    cd cheat.sh-vim/
    cp -r ./* ~/.vim

## Configuration

Every parameter used to retrieve and display the cheat sheet can be changed, to
do so, just put the following in you vimrc and ajust to your needs (these are
the default values that will be used if you do not change them) :

    " Vim command used to open new buffer
    let g:CheatSheetReaderCmd='new"'

    " Cheat sheet file type
    let g:CheatSheetFt='markdown'

    " Program used to retrieve cheat sheet with its arguments
    let g:CheatSheetUrlGetter='curl --silent'

    " cheat sheet base url
    let g:CheatSheetBaseUrl='cheat.sh'

    " cheat sheet settings
    let g:CheatSheetUrlSettings='Tq'

You can also disable the mappings (see plugin/cheat.vim to redo the mappings
manually)

    let g:CheatSheetDoNotMap=1

## License

This plugin is distributed under GPL Licence v3.0, see
https://www.gnu.org/licenses/gpl.txt
