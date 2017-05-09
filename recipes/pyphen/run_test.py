import pyphen

dic = pyphen.Pyphen(lang='nl_NL')
assert dic.inserted('lettergrepen') == 'let-ter-gre-pen'
