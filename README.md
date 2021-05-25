# AVE

autohotkey vi-mode for windows explorer

# usage

- switch keymaps (press 'i' to input, ESC back)
- explorer navigation (bind with origin shortcuts)
- open with (open with any specific application, instead of system default)
- file operation (copy paste rename ...)
- use template file (copy sample file or folder in current directory)
- manipulate clipboard (store clipboard data, reuse it later)
- marked your path (every section can use 50+ symbol)
- launcher (go to everywhere by press one key, search web instantly)
- preview text file (try to read and show any UTF-8 file text)
- compression & decompression (require Bandzip installed)
- global keymaps (windows switch, style toggle)
- some original windows shortcuts are preserved, such as WIN+d WIN+e

# list of key

|  key   |  origin |
| :--:    |  :--          |
| Esc     |   enable function   |
| i       |   disable function  |
| hjkl    |     ←↓↑→        |
| a       |   home          |
| g       |   End           |
| e       |   PageUp        |
| d       |   PageDown      |
| -       |   Alt+Up        |
| [       |   Alt+left      |
| ]       |   Alt+Right     |
| ?       |   shift+F10     |
| t       |   switch control focus  |
| f       |   focus to [char]  |
| ;       |   repeat last 'f'  |
| y       |   ctrl+c    |
| p       |   ctrl+v    |
| c       |   ctrl+x    |
| r       |   F2        |
| u       |   ctrl+z    |
| ctrl+r  |   ctrl+y    |
| \       |   copy file path |
| x       |   move selected files to one folder |
| b       |   manipulate clipboard |
| shift+b |   read from saved register .cb file |
| v       |   open with 'app'       |
| ctrl+v  |   open with 'app'[char] |
| :  | launch cmd.exe |
| n  | copy template file to current directory |
| s  | open disk A:\~Z:\ |
| o  | open system predefined path |
| m        | mark files |
| shift+m  | delete mark|
| '        | execute mark |
| "        | execute mark as Administrator |
| ctrl+m        |  next mark group |
| ctrl+shift+m  |  previous mark group  |
| ,       | open preview windows |
| .       | close preview windows |
| z       | archieve compression or decompression, need Bandzip or PeaZip |
| q       | open query box, search on web |
| win+/   | switch to windows (global) |
| win+F2  | windows AlwaysOnTop (global) |
| win+F1  | hide title (global) |
| win+F3  | transparent windows (global) |

before try, don't forgot change 'AVE.ahk' 15th lines:

```autohotkey
confini := "AVE-CONF.ini"
```

