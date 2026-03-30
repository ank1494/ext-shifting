recursiveRevLex = (e,l) -> if l == 0 then {{}} else if e-l == 0 then {toList (0..e-1)} else join(recursiveRevLex(e-1,l), apply(recursiveRevLex(e-1,l-1), r->append(r,e-1)))
recursiveLex = (s,v,l) -> if l == 0 then {{}} else if s + l == v then {toList (s..v-1)} else join(apply(recursiveLex(s+1,v,l-1), r-> prepend(s,r)), recursiveLex(s+1,v,l))
LexOrder = (v,l) -> recursiveLex(0,v,l)
RevLexOrder = (v,l) -> recursiveRevLex (v,l)