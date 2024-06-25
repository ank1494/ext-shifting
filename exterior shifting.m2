allNonegInts = lst -> all(lst, i->(ZZ === class i and i >= 0))

validateForExtShift = (simplices, fullOrder) -> (
    fSimplices := set flatten simplices; 
    fFullOrder := set flatten fullOrder;
    if not isSubset(fSimplices, fFullOrder) then error "full order does not account for all vertices";
    if not allEqLengths join(simplices,fullOrder) then error "inconsistent simplex dimensions";
    if not allNonegInts(toList (fSimplices+fFullOrder)) then error "vertices must be nonnegative integers";
    );

getMatrixOld = (n, k) -> randomMatrix(n,k);

getMatrixNew = n -> genericMatrix(frac QQ[x_1..x_(n*n)],n,n);

exteriorShift = (simplices, fullOrder) -> (
	sortedSimps := simplices / (i -> sort i);
    validateForExtShift(sortedSimps, fullOrder); 
    v := 1 + max flatten fullOrder;
    l := #(fullOrder_0);
    Mat := compound(getMatrixOld(v,l), sortedSimps, fullOrder);
    result := if rank submatrix(Mat,{0}) > 0 then {0} else {};
    r := rank Mat; 
    for i from 1 to (#fullOrder - 1) do (
		if r == #result then break; 
		if (rank submatrix(Mat,0..i))>(rank submatrix(Mat,0..i-1)) then result = append(result,i);
    );
    sort bump toList apply(result, i -> fullOrder_i)
    )
extShiftLex = simplices -> 
      if #simplices == 0 then set {} else (
      	  if not allEqLengths simplices then error "simplices must all be same dimension";
          v := 1 + max flatten simplices;
      	  l := #(simplices_0);
      	  lexOrd := LexOrder(v,l);
      	  exteriorShift(simplices, lexOrd)
      );
extShiftRevLex = simplices -> 
      if #simplices == 0 then set {} else (
      	  if not allEqLengths simplices then error "simplices must all be same dimension";
          v := 1 + max flatten simplices;
      	  l := #(simplices_0);
      	  revlexOrd := RevLexOrder(v,l);
      	  exteriorShift(simplices, revlexOrd)
      );

exteriorShiftN = (simplices, fullOrder) -> (
    validateForExtShift(simplices, fullOrder); 
    v := 1 + max flatten fullOrder;
    l := #(fullOrder_0);
    print "getting compound matrix";
    Mat := compound(getMatrixNew(v), simplices, fullOrder);
    result := {};
    r := rank Mat;
    currentRank := 0;
    for i from 0 to (#fullOrder - 1) do (
		if r == #result then break; 
		nextSubMtrx := submatrix(Mat,append(result,i));
		--debugging:
		print "i: "; print i; 
		print "currentRank: "; print currentRank; 
		print "nextSubMtrx:"; print nextSubMtrx;
		--end debugging
		if (rank nextSubMtrx)> currentRank then (
			result = append(result,i);
			currentRank = currentRank + 1;
	    );
    );
    set apply(result, i -> fullOrder_i)
);

extShiftLexN = simplices -> 
      if #simplices == 0 then set {} else (
      	  if not allEqLengths simplices then error "simplices must all be same dimension";
          v := 1 + max flatten simplices;
      	  l := #(simplices_0);
      	  lexOrd := LexOrder(v,l);
      	  exteriorShiftN(simplices, lexOrd)
);
  
extShiftRevLexN = simplices -> 
      if #simplices == 0 then set {} else (
      	  if not allEqLengths simplices then error "simplices must all be same dimension";
          v := 1 + max flatten simplices;
      	  l := #(simplices_0);
      	  revlexOrd := RevLexOrder(v,l);
      	  exteriorShiftN(simplices, revlexOrd)
);
