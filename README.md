Lua interactive help
====================

Copy `ihelp.lua` to somewhere in your Lua module path.

To get started:

    $ lua -e "help = require'ihelp'"
    > help()

To customize it for your application: 

    $ lua -l help
    > help"customize"

and do what it says.

Alternatively, copy the help source into your own application and 
provide your own `shorthelp` string and `longhelp` table.

With an existing LDoc-compatible module, e.g. `ml` (Microlight):

    $ lua -l ml -l help
    > help(ml)

and take it from there.

The module used to be called `help` but it seems `help.lua` is a popular
filename. [Project homepage](https://github.com/dlaurie/lua-ihelp)

