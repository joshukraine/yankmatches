# yankmatches.vim

This is my fork of Damian Conway's [yankmatches.vim](https://github.com/thoughtstream/Damian-Conway-s-Vim-Setup/blob/master/plugin/yankmatches.vim). I've made some minor customizations as specified below. I am mainly storing the plugin in my own repo so that I can manage its installation with [Vundle](https://github.com/VundleVim/Vundle.vim).

### Customized Key Mappings

I don't like the delay after pressing `y` for doing regular yanks. Therefore, I've changed the default `ym` mapping to `YM`. The inverse of this is changed from `YM` to `YI`.


	nmap <silent> dm  :     call ForAllMatches('delete', {})<CR>
	nmap <silent> DM  :     call ForAllMatches('delete', {'inverse':1})<CR>
	nmap <silent> YM  :     call ForAllMatches('yank',   {})<CR>
	nmap <silent> YI  :     call ForAllMatches('yank',   {'inverse':1})<CR>
	vmap <silent> dm  :<C-U>call ForAllMatches('delete', {'visual':1})<CR>
	vmap <silent> DM  :<C-U>call ForAllMatches('delete', {'visual':1, 'inverse':1})<CR>
	vmap <silent> YM  :<C-U>call ForAllMatches('yank',   {'visual':1})<CR>
	vmap <silent> YI  :<C-U>call ForAllMatches('yank',   {'visual':1, 'inverse':1})<CR>

### Configuration Options

#### Override the Destination Default Destination Register

By default, this plugin will save your matched text in the register defined by
the `clipboard` setting, or if that isn't defined it will save in the `"`
register.

However, It is possible that a user may want to use a different register for
this plugin.

To configure the destination register to the `a` register for example:

```vimscript
let g:YankMatches#ClipboardRegister='a'
```
