# Vim Shortcuts


## Normal Mode

Shortcut  | Description
--------  | -----------
,es       | Edit file from current directory in new split
,et       | Edit file from current directory in new tab
,ev       | Edit file from current directory in new horizontal split
,ew       | Edit file from current directory in current window
,h        | Clear search highlighting
,i        | Fix indentation
,l        | Show hidden characters
,n        | Toggle line numbering
,s        | Toggle spellcheck
,ve       | Edit .vimrc in new tab
,vr       | Reload vimrc
,w        | Remove trailing whitespace
CTRL-h    | Switch to left window
CTRL-j    | Switch to bottom window
CTRL-k    | Switch to top window
CTRL-l    | Switch to right window
CTRL-Up   | Move line up
CTRL-Down | Move line down


## Visual Mode

Shortcut  | Description
--------  | -----------
CTRL-Up   | Move line up
CTRL-Down | Move line down



## Insert Mode

Shortcut | Description
-------- | -----------
F5       | Toggle paste mode
F6       | Toggle wordwrap



# Vim Plugin Commands


## Ale

Command | Description
------- | -----------
,j      | Previous error
,k      | Next error


## Eunuch.vim

Command    | Description
-------    | -----------
:Delete    | Delete a buffer and the file on disk simultaneously
:Unlink    | Like :Delete, but keeps the now empty buffer
:Move      | Rename a buffer and the file on disk simultaneously
:Rename    | Like :Move, but relative to the current file's containing directory
:Chmod     | Change the permissions of the current file
:Mkdir     | Create a directory, defaulting to the parent of the current file
:Find      | Run find and load the results into the quickfix list
:Locate    | Run locate and load the results into the quickfix list
:Wall      | Write every open window. Handy for kicking off tools like guard
:SudoWrite | Write a privileged file with sudo
:SudoEdit  | Edit a privileged file with sudo



## Exchange.vim

To perform an exchange, run command on the first item then on the second item.

Command    | Description
-------    | -----------
cx{motion} | Exchange 2 items
cxx        | Exchange 2 lines
X          | Exchange 2 visual mode selections
cxc        | Clear any pending exchanges



## Fugitive.git

Command  | Description
-------  | -----------
:Gwrite  | Stage the current file to the index
:Gread   | Revert current file to last checked in version
:Gremove | Delete the current file and the corresponding Vim buffer
:Gmove   | Rename the current file and the corresponding Vim buffer
:Gcommit | Opens up a commit window in a split window
:Gblame  | Opens a vertically split window containing annotations for each line of the file
:Gstatus | Opens a git status window
:Gdiff   | Opens a git diff window

### Gstatus Commands

Command | Description
------- | -----------
CTRL-n  | Next file
CTRL-p  | Previous file
-       | Add or reset file
Enter   | Open file in window below
C       | :Gcommit

### Gdiff Commands

Command     | Description
-------     | -----------
:Gwrite     | Write this window to other window
:Gread      | Read other window into this window
:diffupdate | Update highlighting of both windows
:diffget    | Get change from other window
:diffput    | Put change into other window



## GitGutter
Command | Description
------  | -----------
[c      | Previous hunk (change)
]c      | Next hunk (change)
,hs     | Stage hunk
,hu     | Unstage hunk



## NERDCommenter

Command   | Description
-------   | -----------
,cc       | Comment line or selection
,cn       | Nested comment
,c<space> | Toggle comment
,cm       | Comment lines with one set of delimeters
,ci       | Toggle comments on selected lines
,cs       | Block comment selected lines
,c$       | Comment to end of line
,cA       | Append commect to end of line
,cu       | Uncomment selected lines




## Tabular

Command                  | Description
--------                 | ------------
:Tabularize /{delimiter} | Create table separated by delimiter



## Vim-Surround

Command | Description
------- | -----------
cs"(    | Change surrounding " to (
ds"     | Delete surrounding "
S"      | Surround selection with "



## Unimpaired.vim
Command  | Description       | Vim Command
-------- | -----------       | -----------
[a       | Previous file     | :previous
]a       | Next file         | :next
[A       | First file        | :first
]A       | Last file         | :last
[b       | Previous buffer   | :bprevious
]b       | Next buffer       | :bnext
[B       | First buffer      | :bfirst
]B       | Last buffer       | :blast
[l       | Previous location | :lprevious
]l       | Next location     | :lnext
[L       | First Location    | :lfirst
]L       | Last location     | :llast
[q       | Previous quickfix | :cprevious
]q       | Next quickfix     | :cnext
[Q       | First quickfix    | :cfirst
]Q       | Last quickfix     | :clast
[t       | Previous tag      | :tprevious
]t       | Next tag          | :tnext
[T       | First tag         | :tfirst
]T       | Last tag          | :tlast
