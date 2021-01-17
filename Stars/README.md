# Stars

An addon which filters messages based on a filter. Original post: https://www.ffxiah.com/forum/topic/53964/block-those-stars/2/#3448473

## Adding more words to filter

Modify line 13 in `stars.lua` to change what gets filtered.
[More info about pattern matching in lua.](https://riptutorial.com/lua/example/20315/lua-pattern-matching)

### Examples on filters

```local blackListedWords = T{string.char(0x81,0x99),string.char(0x81,0x9A),'Job Points', 'Faster', 'kill', 'Kill', 'Fast Cast', 'Shop', 'shop', 'delivery', 'Midle-man', 'Stock', 'stock', '1%-99', 'Job Point.2100', 'job points', 'Buy?', 'Job Point.500', 'JP.2100', 'JP.500', 'Capacity Point.2100', 'Capacity Point.500', 'CP.2100', 'CP.500', '★', '★★', '★★★', '★ ', '★★ ', '★★★ ', 'save', 'Save'} -- First two are '☆' and '★' symbols.```
