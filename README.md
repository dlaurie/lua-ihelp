lua-ihelp
=========

Interactive help for Lua programs. Copy `help.lua` to somewhere in
your Lua module path.

To get started:

    $ lua -l help
    help()

To customize it for your application: 

    $ lua -l help
    help"customize"

and do what it says.

Alternatively, include the help source in your application and provide 
your own `shorthelp` string and `longhelp` table.

With an existing LDoc-compatible module, e.g. Microlight:

    $ lua -l ml -l help
    help(ml)

and take it from there.


