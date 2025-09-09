if exists("g:loaded_show_type")
  finish
endif
let g:loaded_show_type = 1

command! ShowType lua require('show_type').show()
