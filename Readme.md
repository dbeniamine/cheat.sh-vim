*This repository is a mirror, for developpement and issues, please go to [gitlab](https://gitlab.com/dbeniamine/cheat.sh-vim/)*

# Vim Cheat.sh

This is a highly configurable vim plugin to browse cheat sheet from
[cheat.sh](https://github.com/chubin/cheat.sh) directly from vim.

## Demo

<!-- There is an asciinema showing how it works :

[![asciicast](https://asciinema.org/a/c6QRIhus7np2OOQzmQ2RNXzRZ.png)](https://asciinema.org/a/c6QRIhus7np2OOQzmQ2RNXzRZ)
-->

There is a demo of most important features of the cheat.sh Vim plugin (5 Min),
courtesy of @chubin, CC-SA.

** Note :** In the video, @chubin uses the `space` key as a `<leader>`, by
default vim `<leader>` is `backslash`.

<p align="center">
  <img src='https://cheat.sh/files/vim-demo.gif'/>
</p>

Or, if you want to scroll and/or pause, the same on YouTube:

<p align="center">
  <a href="http://www.youtube.com/watch?feature=player_embedded&v=xyf6MJ0y-z8
  " target="_blank"><img src="http://img.youtube.com/vi/xyf6MJ0y-z8/0.jpg" 
  alt="cheat.sh-vim: Using cheat.sh from vim" width="700" height="490" border="10" /></a>
</p>

## Features

+ Browse existing cheat sheets from cheat.sh directly from vim
+ Get answers on any programming question directly on your vim with simple mappings
+ Send compilation / syntax error to cht.sh and get answers
+ Manage session id to replay last query from other cht.sh clients
+ Quick navigation through answers
+ Everything is configurable

### How to use it

The easiest way to use this plugin is to use one of the following mappings :

+ `K` get answer on the word under the cursor or the selection on a pager (this
feature requires vim >= 7.4.1833, you can check if have the right version with :
`:echo has("patch-7.4.1833")`)
+ `<leader>KK` same as `K` but works on lines or visual selection (not working
on neovim, because they killed interactive commands with `:!`)
+ `<leader>KB` get the answer on a special buffer
+ `<leader>KR` Replace your question by the answer
+ `<leader>KP` Past the answer below your question
+ `<leader>KC` Replay last query, toggling comments
+ `<leader>KE` Send first error to cht.sh
+ `<leader>C` Toggle showing comments by default see [configuration](#configuration)
+ `<leader>KL` Replay last query

The plugins also provides four main commands :

    :Cheat
    :CheatReplace
    :CheatPast
    :CheatPager

+ These commands takes 0 or 1 argument.
+ If you give no argument, it will send the language of the current buffer and
the visual selection (or the current line / word in `normal` mode) as a plus
query to cheat.sh and show the answer in a new buffer (`:Cheat`), in place of
your question (`:CheatReplace`) or in a pager (`:CheatPager`).
+ If one argument is given, you can complete it from a list of available cheat
sheets or write your own [query](https://github.com/chubin/cheat.sh#search).
+ They also take a `bang` that make same transform the query into a plus query:
for instance : `:Cheat! factory` is the same as `:Cheat &ft/factory+`.

#### Ids

It also provides the `:CheatId` command to manage ids :

    :Cheat[!] [newid]         " Generates a new id or set id to newid
                              " Id will not be overwritten if ! is not given
    :Cheat remove             " Completely removes the id

#### Errors

Cheat.sh-vim can directly send the syntaxt and compilation errors / warning to
cht.sh. To do so, hit `<leader>KE` or run `:CheatError`.

By default, the answer will be displayed on the cheat buffer, to change this
behavior :

    let g:CheatSheetDefaultMode = x

Where x is :

+ 0 : Cheat buffer (default)
+ 1 : Replace current line (sounds like a very bad idea)
+ 2 : Use the pager
+ 3 : Append answer below current line (sounds like a bad idea)

##### Error providers

Currently errors are search from the quickfix, then from syntastic errors.
To change this order :

    let  g:CheatSheetProviders = ['syntastic', 'quickfix']

You can easily add an error provider in 5 steps :

1. Copy the file `cheat.sh/autoload/cheat/providers/quickfix.vim` to
`cheat.sh/autoload/cheat/providers/myprovider.vim`
2. Adapt and rename the function (only change quickfix in the name), it must
return the error string without special chars or an empty string if there are
no errors / warning
3. Add your provider name (filename) to the `CheatSheatProvider` list in
`cheat.sh/autoload/cheat/providers.vim`
4. Test it
5. Do a merge request on [gitlab](https://gitlab.com/dbeniamine/cheat.sh-vim/)

##### Syntastic hooks

Cheat.sh-vim uses syntastic hooks to retrieve the error list, if you also need
to use synstastic hook, make sure that your function calls ours with the initial
error list :

    function SyntasticCheckHook(errors)
        call cheat#providers#syntastic#Hook(a:errors)
        " Do whatever you want to do
    endfunction

#### Navigate

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

In the cheat buffer, the following mappings are also available :

+ `<localleader>h` Previous Answer
+ `<localleader>j` Next Question
+ `<localleader>k` Previous Question
+ `<localleader>l` Next Answer
+ `<localleader>H` Previous history
+ `<localleader>J` Next "See also"
+ `<localleader>K` Previous "See also"
+ `<localleader>L` Next history


You can also directly use the function :

    :call cheat#navigate(delta, type)

Where delta is a numeric value for moving (1, or -1 for next or previous) And
type is one of : `'Q'`, `'A'`, `'S'`, `H` (history), and `C` (replay last
query, toggling comments).

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

    " Flag to add cookie file to the query
    let g:CheatSheetUrlGetterIdFlag='-b'

    " cheat sheet base url
    let g:CheatSheetBaseUrl='https://cht.sh'

    " cheat sheet settings do not include style settings neiter comments, 
    " see other options below
    let g:CheatSheetUrlSettings='q'

    " cheat sheet pager
    let g:CheatPager='less -R'

    " pygmentize theme used for pager output, see :CheatPager :styles-demo
    let g:CheatSheetPagerStyle=rrt

    " Show comments in answers by default
    " (setting this to 0 means giving ?Q to the server)
    let g:CheatSheetShowCommentsByDefault=1

    " cheat sheet buffer name
    let g:CheatSheetBufferName="_cheat"

    " Default selection in normal mode (line for whole line, word for word under cursor)
    let g:CheatSheetDefaultSelection="line"

    " Default query mode
    " 0 => buffer
    " 1 => replace (do not use or you might loose some lines of code)
    " 2 => pager
    " 3 => paste after query
    " 4 => paste before query
    let g:CheatSheetDefaultMode=0

     Path to cheat sheet cookie
    let g:CheatSheetIdPath=expand('~/.cht.sh/id')



You can also disable the mappings (see plugin/cheat.vim to redo the mappings
manually)

    let g:CheatSheetDoNotMap=1

To disable the replacement of man by cheat sheets :

    Let g:CheatDoNotReplaceKeywordPrg=1

## License

This plugin is distributed under GPL Licence v3.0, see
https://www.gnu.org/licenses/gpl.txt

The demo are creative Commons, CC-SA Igor Chubin.
