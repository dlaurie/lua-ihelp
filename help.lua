--- help.lua (c) Dirk Laurie 2013, Lua-style MIT license
-- To get started:
--
--$ lua -l help
--help()


do
-- sample shorthelp and longhelp
local shorthelp = [[
The following functions are provided:
   help
Try `help"topic"`, e.g. help"all", or `help(function)`, e.g. `help(help)`.]]

local longhelp = {
method = [[
`debug.getinfo(fct).source` contains the Lua source code of `fct`,
or the name of the file from which it was loaded, or the information
that it is precompiled C code. If the actual source is available,
a docstring (see `help"docstring"`) is extracted.
]],
bugs = [[
If the source code is read from a file that you are editing, the
version from which the docstring is extracted may be more recent
than the version you have loaded.
]],
docstring = [[
---    The docstring of a function
-- A comment block from the Lua code of a function, formatted in LDoc
-- style, like this block. The comments may come immediately before the 
-- first line of the function or anywhere inside it.  All comments must 
-- start at position of their lines and the first comment must start 
-- with at least three hyphens. For a very short function, the whole 
-- code is used as the docstring. 
--
-- Not available for functions defined from the terminal while running 
-- the standalone Lua interpreter.
]],
customize = [[
After `help(arg,msg)`, where `arg` is nil or any string except `all`, 
the message you get when typing `help(arg)` will be `msg`.
]]
}
--

------------------ no changes needed after this line ------------------

local docstring_pattern = "(\n%-%-%-.-\n)[^%-]"
local starts_with_two_hyphens = "^%-%-"
local starts_with_three_hyphens = "^%-%-%-"
local only_hyphens_at_least_three = "^%-%-(%-)+$"
local nohelp = "No help available"
local code={}
local shortenough = 80

local docstring = function(fct)
---   docstring(fct)
-- Extracts an LDoc-styled comment block from the Lua code of a function, 
-- for example this block. The comments may come immediately before the
-- first line of the function or anywhere inside it.  All comments must 
-- start at position 1 of their lines and the first comment must start 
-- with at least three hyphens.
   local getinfo = debug.getinfo
   local helptext
   if getinfo and getinfo(fct) then
      local info=getinfo(fct)
      local source=info.source
      helptext = source:match(docstring_pattern)
      if not helptext then
         if source:match"%=%[C%]" then return "Precompiled C function"      
         elseif source:match"%=stdin" then return "Defined above"
         elseif source:match'%@(.+)' then  -- source filename provided
            local filename=source:match'%@(.+)'
            local sourcefile = io.open(filename)
            if not code[filename] then  -- memoize source code
               local c={}
               for k in sourcefile:lines() do c[#c+1]=k end
               code[filename]=c
            end
            local fcode=code[filename]
            helptext={}
            local start, stop = info.linedefined, info.lastlinedefined
            local k=start-1  -- first try the preceding comment block
            while fcode[k]:match(starts_with_two_hyphens) do 
               if fcode[k]:match(only_hyphens_at_least_three) then break end
               table.insert(helptext,1,fcode[k]) 
               if fcode[k]:match(starts_with_three_hyphens) then break end
               k=k-1
               if k==0 then break end
            end
            if #helptext>0 then helptext=table.concat(helptext,'\n')
            else  -- try function body
               for k=start,stop do
                  helptext[#helptext+1] = fcode[k]
               end
               fcode = helptext
               if #helptext>0 then 
                  helptext=table.concat(helptext,'\n')
                  helptext = helptext and helptext:match(docstring_pattern)
               else helptext=nil
               end 
               -- last resort: full code if it is short enough
               if not helptext and (#fcode<=shortenough) then 
                  helptext=table.concat(fcode,'\n') 
               end
            end
         end
      end
   end 
   return helptext 
end

local fold
fold = function(s)
--- Primitive word-wrap function. If you want to use it independently, 
-- remove the line declaring it to be local.
  if #s<=72 then return s end
  local n=74
  while n>50 do n=n-1; if s:sub(n,n):match"%s" then break end end
  return s:sub(1,n-1)..'\n    '..fold(s:sub(n+1))
end  

local topics = function (tbl,prefix)
   local t={}
   for k in pairs(tbl) do t[#t+1]=(prefix or '')..k end   
   table.sort(t)
   return table.concat(t,' ')
end

local help = function(fct,...)
---    help(fct)
-- none: Prints short help. 
-- function: Prints the docstring of `fct`, if any.
-- table: Prints `help` field, if any; else contents.
-- string: Prints help on the topic, if any.
-- "all": Prints available topics. 
   local helptext
   local dump = string.dump
   if select('#',...)>1 then print('Too many arguments: try `help(help)`')
   elseif type(fct)=='string' and fct~='all' and select('#',...)==1 then
      longhelp[fct]=...
   elseif fct==nil then 
      if select('#',...)>0 then shorthelp=... else print(shorthelp) end
   elseif select('#',...)>0 then 
      print('help cannot be redefined for '..tostring(fct))
   elseif fct=='all' then
      print (fold("Help available on these topics:  "..topics(longhelp)))
   elseif longhelp[fct] then print(longhelp[fct])   
   elseif type(fct)=="table" then 
      if type(fct.help)=='string' then print(fct.help)
      else print(fold("Contents: "..topics(fct)))
      end
   elseif type(fct)=='function' then print(docstring(fct) or nohelp)
   else print("Don't know how to find help for "..tostring(fct))
   end
end

return help

end   