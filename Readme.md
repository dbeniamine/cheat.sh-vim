# Vim Cheat.sh

This is a highly configurable vim plugin to browse cheat sheet from
[cheat.sh](https://github.com/chubin/cheat.sh) directly from vim.

There is an asciinema showing how it works :

[![asciicast](https://asciinema.org/a/c6QRIhus7np2OOQzmQ2RNXzRZ.png)](https://asciinema.org/a/c6QRIhus7np2OOQzmQ2RNXzRZ)

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
    cd vim-mail/
    cp -r ./* ~/.vim

## Features

This plugin provides a `:Cheat` command to browse cheat sheets from vim. This
command takes one argument : a Cheat.sh [query](https://github.com/chubin/cheat.sh#search), and supports completion.

For more info on cheat sheet sources, see
[cheat.sh](https://github.com/chubin/cheat.sh).

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

## License

This plugin is distributed under GPL Licence v3.0, see
https://www.gnu.org/licenses/gpl.txt
