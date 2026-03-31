-- The partial order on simplices: a <= b (componentwise) iff a_i <= b_i for all i.
-- This is the product order on {0,...,v-1}^k restricted to strictly increasing sequences.

-- Returns true if a <= b componentwise (a is below b in the partial order on simplices).
isPartialLeq = (a, b) -> (
    if #a != #b then error "sequences must be equal in length";
    result := true;
    for i from 0 to #a - 1 do (
        if not result then break;
        result = a_i <= b_i;
    );
    result
    )

doc ///
  Key
    isPartialLeq
  Headline
    test whether one simplex is below another in the componentwise partial order
  Usage
    isPartialLeq(a, b)
  Example
    isPartialLeq({0,1}, {0,2})
///

-- Returns the indices in fullord of all elements strictly below el in the partial order
-- and appearing before el in fullord. Stops at el.
elementsPartialLessThan = (el, fullord) -> (
    els := {};
    for i from 0 to #fullord - 1 do (
        if el == fullord_i then break;
        if isPartialLeq(fullord_i, el) then els = append(els, i);
    );
    els
    )

doc ///
  Key
    elementsPartialLessThan
  Headline
    find indices of elements strictly below a simplex in the componentwise partial order
  Usage
    elementsPartialLessThan(el, fullord)
  Example
    elementsPartialLessThan({0,2}, LexOrder(4,2))
///

-- Computes an unnammed partial exterior shift using the componentwise partial order on simplices.
-- Constructs the compound matrix as in exteriorShift. Includes simplex s (at index i in lexOrd) iff
-- its column is not in the span of columns from simplices strictly below s in the partial order.
-- Differs from exteriorShift in that the greedy selection uses only the partial-order predecessors
-- of each candidate, not all previously selected columns.
partialShift = simplices -> if #simplices == 0 then set {} else (
    if not allEqLengths simplices then error "simplices must all be same dimension";
    vertexBound := 1 + max flatten simplices;
    simplexDim := #(simplices_0);
    lexOrd := LexOrder(vertexBound, simplexDim);
    validateForExtShift(simplices, lexOrd);
    Mat := compound(randomMatrix(vertexBound, simplexDim), (simplices / (i -> sort i)), lexOrd);
    resultIndices := if rank submatrix(Mat, {0}) > 0 then {0} else {};
    for i from 1 to #lexOrd - 1 do (
        lessThan := elementsPartialLessThan(lexOrd_i, lexOrd);
        if (rank submatrix(Mat, lessThan)) < (rank submatrix(Mat, append(lessThan, i))) then resultIndices = append(resultIndices, i);
    );
    set lexOrd_resultIndices
    )

doc ///
  Key
    partialShift
  Headline
    compute the partial exterior shift using the componentwise partial order
  Usage
    partialShift simplices
  Example
    partialShift {{1,2},{1,3},{2,3}}
///
