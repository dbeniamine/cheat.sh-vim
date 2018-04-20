# Vim Cheat.sh

This is a vim plugin to browse cheat sheat from [cheat.sh](https://github.com/chubin/cheat.sh) directly from vim.
## Installation

## Install

### Vizardry

If you have [Vizardry](https://github.com/dbeniamine/vizardry) installed, you
can run from vim:

    :Invoke -u dbeniamine cheat.sh-vim

### Pathogen install

    git clone https://github.com/dbeniamine/cheat.sh-vim.git ~/.vim/bundle/cheat.sh-vim

### Quick install

    git clone https://github.com/dbeniamine/cheat.sh-vim.git
    cd vim-mail/
    cp -r ./* ~/.vim

## Features

This plugin provides a `:Cheat` command to browse cheat sheets from vim. This command takes one argument : a Cheat,sh query, and supports completion.

For more info on cheat sheet source, see [cheat.sh](https://github.com/chubin/cheat.sh).

## Configuration

You can configure the viewer command used to read cheat.sh, by adding this line to your vimrc and adapting it to your needs (this is the defautl value)

    let g:CheatSheatReaderCmd='view -c "set ft=markdown"'

## License

This plugin is distributed under GPL Licence v3.0, see
https://www.gnu.org/licenses/gpl.txt
