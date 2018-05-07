# Vim Cheat.sh

This is a highly configurable vim plugin to browse cheat sheet from
[cheat.sh](https://github.com/chubin/cheat.sh) directly from vim.

There is an asciinema showing how it works :

[![asciicast](https://asciinema.org/a/c6QRIhus7np2OOQzmQ2RNXzRZ.png)](https://asciinema.org/a/c6QRIhus7np2OOQzmQ2RNXzRZ)

## Features

+ Browse existing cheat sheets from cheat.sh directly from vim
+ Get answers on any programming question directly on your vim with simple mappings
+ Quick navigation through answers
+ Everything is configurable

### How to use it

The easiest way to use this plugin is to use one of the following mappings :

+ `K` get answer on the word under the cursor or the selection on a pager
+ `<leader>kK` same as `K`
+ `<leader>KB` get the answer on a special buffer
+ `<leader>KR` Replace your question by the answer
+ `<leader>KC` Replay last query, toggling comments

The plugins also provides two main commands :

    :Cheat
    :CheatReplace

+ These commands takes 0 or 1 argument.
+ If you give no argument, it will send the language of the current buffer and
the visual selection (or the current line in `normal` mode) as a query to
cheat.sh and show the answer in a new buffer (`:Cheat`) or in place of your
question (`:CheatReplace`).
+ If one argument is given, you can complete it from a list of available cheat
sheets or write your own [query](https://github.com/chubin/cheat.sh#search).
+ There are two mappings `<localeader>KB` and `<leader>KR` (Cheat Replace)
to run these commands without any arguments.

It also adds a `:CheatPager` command that is not designed to be directly used
by the end user. This command is used to lookup cheat sheets instead of calling
`man` when you hit `K` in normal and visual modes.

#### Navigate through answers

Once you have called on of these commands, you can navigate through questions,
answers and related with the following mappings :

+ `<leader>KQN` Next Question
+ `<leader>KAN` Next Answer
+ `<leader>KSN` Next "See also"
+ `<leader>KHN` Next in history
+ `<leader>KQP` Previous Question
+ `<leader>KAP` Previous Answer
+ `<leader>KSP` Previous "See also"
+ `<leader>KHP` Previous in history

You can also directly use the function :

    :call cheat#navigate(delta, type)

Where delta is a numeric value for moving (1, or -1 for next or previous) And
type is one of : `'Q'`, `'A'`, `'S'`, `H` (history), and `C` (same as history
but toggle comments)

For instance :

    :call cheat#navigate(-3, 'A')

goes back three answers before the current

When navigating, the same mode (pager, buffer, replace) is used as for the last
request.

#### Notes

+ `<leader>` is usually '\'.
+ **This plugin is still in beta, Replace mode might remove some of your code,
use with caution.**
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

    " cheat sheet settings do not include style settings neiter comments, 
    " see other options below
    let g:CheatSheetUrlSettings='q'

    " pygmentize theme used for pager output, see :CheatPager :styles-demo
    let g:CheatSheetPagerStyle=rrt

    " Show comments in answers by default
    " (setting this to 0 means giving ?Q to the server)
    let g:CheatSheetShowCommentsByDefault=1

    " cheat sheet pager command
    let g:CheatPager='less -R'

    " cheat sheet buffer name
    let g:CheatSheetBufferName="_cheat"

    " Default selection in normal mode (line for whole line, word for word under cursor)
    let g:CheatSheetDefaultSelection="line"

You can also disable the mappings (see plugin/cheat.vim to redo the mappings
manually)

    let g:CheatSheetDoNotMap=1

To disable the replacement of man by cheat sheets :

    Let g:CheatDoNotReplaceKeywordPrg=1

## License

This plugin is distributed under GPL Licence v3.0, see
https://www.gnu.org/licenses/gpl.txt
