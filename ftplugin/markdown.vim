command! -nargs=0 StructChineseLawText2Markdown :call <SID>StructChineseLawText2Markdown()
noremap <silent> <Plug>StructChineseLawText2Markdown :StructChineseLawText2Markdown<cr>
function! s:StructChineseLawText2Markdown()
  let l:unnamed = getreg('"')
  let l:lines = getline(1, '$')
  call map(l:lines, 'trim(v:val)')
  let LawChangeLogPattern = '^（\([^（）]\+\)）$'
  while match(l:lines, LawChangeLogPattern) >= 0
    let idx = match(l:lines, LawChangeLogPattern)
    let line = substitute(l:lines[idx], LawChangeLogPattern, '\1', 'g')
    let lst = split(line, '　\+')
    call map(lst, '"- " . v:val')
    let l:lines = l:lines[:idx-1] + lst + l:lines[idx+1:]
  endwhile
  call map(l:lines, 'substitute(v:val, "[　\\u2000-\\u200a]", " ", "g")')
  call map(l:lines, 'substitute(v:val, "[､、]\\s*", "、", "g")')
  call map(l:lines, 'substitute(v:val, "[,，]\\s*", "，", "g")')
  call map(l:lines, 'substitute(v:val, "[;；]\\s*", "；", "g")')
  call map(l:lines, 'substitute(v:val, "[:：]\\s*", "：", "g")')
  call map(l:lines, 'substitute(v:val, "[｡。]\\s*", "。", "g")')
  call map(l:lines, 'substitute(v:val, " \\+", " ", "g")')
  call map(l:lines, 'trim(v:val)')
  call map(l:lines, 'substitute(v:val, "^#\\{2,}\\s*", "", "g")') " 二级标题以下的标题，全部去除；后面的代码将会按新规则来确定标题等级
  call filter(l:lines, 'strlen(v:val)')
  let partLevel = "##"
  let chapterLevel = "##"
  let sectionLevel = "##"
  " 名称的标题等级是一级#，默认编、章、节的标题等级都是二级##，如果发现存在“编”，就将“章”、"节“的标题等级降一级，同理，如果发现”章"，就将“节"的标题等级降一级
  if match(l:lines, '^\(第[零一二三四五六七八九十百千万]\+编\)\s*') >= 0
    call map(l:lines, 'substitute(v:val, "^\\(第[零一二三四五六七八九十百千万]\\+编\\)\\s*", "' . partLevel    . ' \\1 ", "")')
    let chapterLevel .= "#"
    let sectionLevel .= "#"
  endif
  if match(l:lines, '^\(第[零一二三四五六七八九十百千万]\+章\)\s*') >= 0
    call map(l:lines, 'substitute(v:val, "^\\(第[零一二三四五六七八九十百千万]\\+章\\)\\s*", "' . chapterLevel . ' \\1 ", "")')
    let sectionLevel .= "#"
  endif
  call map(l:lines, 'substitute(v:val, "^\\(第[零一二三四五六七八九十百千万]\\+节\\)\\s*", "' . sectionLevel . ' \\1 ", "")')

  call map(l:lines, 'substitute(v:val, "^\\(第[零一二三四五六七八九十百千万]\\+条\\(之[零一二三四五六七八九十百千]\\+\\)\\?\\)\\s*", "**\\1** ", "")')
  call map(l:lines, 'substitute(v:val, "[^#*编章节0-9-]\\zs\\s\\+\\ze[\\u4e00-\\u9fff]", "", "g")')
  call map(l:lines, 'substitute(v:val, "^目录$", "## 目录", "g")')
  execute("%delete")
  call setline(1, l:lines)
  execute '1,$-1s/\n\+/\r\r/g'
  call setpos(".", [0, 1, 1, 0])
  call setreg('"', l:unnamed)
  unlet l:lines
  unlet l:unnamed
  " execute "normal! /[^#*编章节0-9-]\\zs\\s\\+\\ze[\\u4e00-\\u9fff]\<cr>"
endfunction
