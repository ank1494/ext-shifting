completeBipartite = (m,n) -> (
	graph := {}; 
	for i from 0 to m-1 do
      for j from m to m+n-1 do 
		graph = append(graph, {i,j}); 
	graph
);

recursiveRevLex = (e,l) -> if l == 0 then {{}} else if e-l == 0 then {toList (0..e-1)} else join(recursiveRevLex(e-1,l), apply(recursiveRevLex(e-1,l-1), r->append(r,e-1)));
recursiveLex = (s,v,l) -> if l == 0 then {{}} else if s + l == v then {toList (s..v-1)} else join(apply(recursiveLex(s+1,v,l-1), r-> prepend(s,r)), recursiveLex(s+1,v,l))
LexOrder = (v,l) -> recursiveLex(0,v,l)
RevLexOrder = (v,l) -> recursiveRevLex (v,l)
randomMatrix = (n,k) -> (
	d := 0; 
	while d == 0 do (
		Mat := random(QQ^n,QQ^n);
		d = det exteriorPower(k,Mat);
		if d != 0 then break Mat;
	);
);
allEqLengths = lst -> (
	lengths := apply(lst, i -> #i); 
	min lengths == max lengths
);
minor = (M,cols,rows) -> det submatrix(M,cols,rows)
compound = (M, rows, cols) -> if not allEqLengths join (rows, cols) then error "not all indices equal in length" else (
      Mut = mutableMatrix(QQ, #rows, #cols); for i from 0 to #rows - 1 do
      for j from 0 to #cols - 1 do
      Mut_(i,j) = minor(M, rows_i, cols_j); matrix Mut)
allNonegInts = lst -> all(lst, i->(ZZ === class i and i >= 0))
                 validateForExtShift = (simplices, fullOrder) -> (fSimplices = set flatten simplices; fFullOrder = set flatten fullOrder;
                 if not isSubset(fSimplices, fFullOrder) then error "full order does not account for all vertices";
                 if not allEqLengths join(simplices,fullOrder) then error "inconsistent simplex dimensions";
                 if not allNonegInts(toList (fSimplices+fFullOrder)) then error "vertices must be nonnegative integers";)
     exteriorShift = (simplices, fullOrder) -> (validateForExtShift(simplices, fullOrder); v = 1 + max flatten fullOrder;
           l = #(fullOrder_0);
                 Mat = compound(randomMatrix(v,l), simplices, fullOrder);
           result = if rank submatrix(Mat,{0}) > 0 then {0} else {};
           r = rank Mat; for i from 1 to (#fullOrder - 1) do (if r == #result then break; if (rank submatrix(Mat,0..i))>(rank submatrix(Mat,0..i-1)) then result = append(result,i);
           );
           set apply(result, i -> fullOrder_i))
extShiftLex = simplices -> if #simplices == 0 then set {} else (
      if not allEqLengths simplices then error "simplices must all be same dimension";
            v = 1 + max flatten simplices;
      l = #(simplices_0);
      lexOrd = LexOrder(v,l);
      exteriorShift(simplices, lexOrd))
extShiftRevLex = simplices -> if #simplices == 0 then set {} else (
      if not allEqLengths simplices then error "simplices must all be same dimension";
            v = 1 + max flatten simplices;
      l = #(simplices_0);
      revlexOrd = RevLexOrder(v,l);
      exteriorShift(simplices, revlexOrd))

isPLTE = (a,b) -> (if #a != #b then error "sequences must be equal in length";
     result = true;
     for i from 0 to #a - 1 do (if not result then break; result = a_i <= b_i;);
               result)
elementsPLT= (el, fullord) -> (els = {};
     for i from 0 to #fullord - 1 do (
     if el == fullord_i then break;
     if isPLTE(fullord_i, el) then els = append(els, i););
     els)
partialShift = simplices -> if #simplices == 0 then set {} else (
           if not allEqLengths simplices then error "simplices must all be same dimension";
                 v = 1 + max flatten simplices;
           l = #(simplices_0);
           lexOrd = LexOrder(v,l);
                         validateForExtShift(simplices, lexOrd);
     Mat = compound(randomMatrix(v,l), simplices, lexOrd);
     resultIndices = if rank submatrix(Mat,{0}) > 0 then {0} else {};
     for i from 1 to #lexOrd - 1 do (
     lessThan = elementsPLT(lexOrd_i, lexOrd);
     if (rank submatrix(Mat, lessThan)) < (rank submatrix(Mat, append(lessThan, i))) then resultIndices = append(resultIndices, i););
     set lexOrd_resultIndices)

