isPLTE = (a,b) -> (
    if #a != #b then error "sequences must be equal in length";
    result = true;
    for i from 0 to #a - 1 do (
	if not result then break; 
	result = a_i <= b_i;
	);
    result
    )
elementsPLT= (el, fullord) -> (
    els = {};
    for i from 0 to #fullord - 1 do (
    	if el == fullord_i then break;
    	if isPLTE(fullord_i, el) then els = append(els, i);
	);
    els
    )
partialShift = simplices -> if #simplices == 0 then set {} else (
    if not allEqLengths simplices then error "simplices must all be same dimension";
    v = 1 + max flatten simplices;
    l = #(simplices_0);
    lexOrd = LexOrder(v,l);
    validateForExtShift(simplices, lexOrd);
    Mat = compound(randomMatrix(v,l), (simplices / (i -> sort i)), lexOrd);
    resultIndices = if rank submatrix(Mat,{0}) > 0 then {0} else {};
    for i from 1 to #lexOrd - 1 do (
    	lessThan = elementsPLT(lexOrd_i, lexOrd);
    	if (rank submatrix(Mat, lessThan)) < (rank submatrix(Mat, append(lessThan, i))) then resultIndices = append(resultIndices, i);
	);
    set lexOrd_resultIndices
    )
