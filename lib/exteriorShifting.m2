-- Validates that simplices and fullOrder are compatible: all simplex vertices appear in fullOrder,
-- all faces have equal dimension, and all vertex labels are non-negative integers.
validateForExtShift = (simplices, fullOrder) -> (
    fSimplices := set flatten simplices;
    fFullOrder := set flatten fullOrder;
    if not isSubset(fSimplices, fFullOrder) then error "full order does not account for all vertices";
    if not allEqLengths join(simplices, fullOrder) then error "inconsistent simplex dimensions";
    if not allNonegInts(toList (fSimplices + fFullOrder)) then error "vertices must be nonnegative integers";
    );

-- Computes the exterior shift of a simplicial complex with respect to a given total order on simplices.
-- Constructs the compound matrix A where rows correspond to the n-faces of the complex and columns
-- to all n-simplices in fullOrder. Entry (i,j) is the minor of a random matrix with rows/cols given
-- by simplices_i and fullOrder_j. Returns the smallest set of simplices in fullOrder whose columns
-- form a basis for the column space of A (equivalently: the greedy basis under the given order).
-- Vertex indices in the result are 1-indexed (incremented from the 0-indexed working representation).
exteriorShift = (simplices, fullOrder) -> (
    sortedSimps := simplices / (i -> sort i);
    validateForExtShift(sortedSimps, fullOrder);
    vertexBound := 1 + max flatten fullOrder;
    simplexDim := #(fullOrder_0);
    Mat := compound(randomMatrix(vertexBound, simplexDim), sortedSimps, fullOrder);
    result := if rank submatrix(Mat, {0}) > 0 then {0} else {};
    targetRank := rank Mat;
    for i from 1 to (#fullOrder - 1) do (
        if targetRank == #result then break;
        if (rank submatrix(Mat, 0..i)) > (rank submatrix(Mat, 0..i-1)) then result = append(result, i);
    );
    sort incrementVertices toList apply(result, i -> fullOrder_i)
    )

doc ///
  Key
    exteriorShift
  Headline
    compute the exterior shift of a simplicial complex under a given total order
  Usage
    exteriorShift(simplices, fullOrder)
  Description
    Example
      exteriorShift({{0,1},{0,2},{1,2}}, LexOrder(3,2))
///

-- Exterior shift under the lex order on {0,...,v-1}.
-- Returns result with 1-indexed vertices.
extShiftLex = simplices ->
    if #simplices == 0 then set {} else (
        if not allEqLengths simplices then error "simplices must all be same dimension";
        vertexBound := 1 + max flatten simplices;
        simplexDim := #(simplices_0);
        lexOrd := LexOrder(vertexBound, simplexDim);
        exteriorShift(simplices, lexOrd)
    );

doc ///
  Key
    extShiftLex
  Headline
    compute the exterior shift of a simplicial complex under the lex order
  Usage
    extShiftLex simplices
  Description
    Example
      extShiftLex {{1,2},{1,3},{2,3}}
///

-- Exterior shift under the reverse-lex order on {0,...,v-1}.
-- Returns result with 1-indexed vertices.
extShiftRevLex = simplices ->
    if #simplices == 0 then set {} else (
        if not allEqLengths simplices then error "simplices must all be same dimension";
        vertexBound := 1 + max flatten simplices;
        simplexDim := #(simplices_0);
        revlexOrd := RevLexOrder(vertexBound, simplexDim);
        exteriorShift(simplices, revlexOrd)
    );

doc ///
  Key
    extShiftRevLex
  Headline
    compute the exterior shift of a simplicial complex under the reverse-lex order
  Usage
    extShiftRevLex simplices
  Description
    Example
      extShiftRevLex {{1,2},{1,3},{2,3}}
///

-- Symbolic (non-random) variant: uses a generic matrix over a fraction field so the result is
-- deterministic.
-- KNOWN ISSUE: exteriorShiftN, extShiftLexN, and extShiftRevLexN are unusable in practice —
-- the generic matrix computation is too large and M2 hangs for any non-trivial input. Do NOT
-- use these functions for testing or computation. Use exteriorShift / extShiftLex / extShiftRevLex
-- instead. For idempotency tests, apply extShiftLex to its own output: an already-shifted complex
-- must be a fixed point of the shift regardless of the random matrix chosen.
exteriorShiftN = (simplices, fullOrder) -> (
    validateForExtShift(simplices, fullOrder);
    vertexBound := 1 + max flatten fullOrder;
    simplexDim := #(fullOrder_0);
    Mat := compound(genericMatrix(frac QQ[x_1..x_(vertexBound*vertexBound)], vertexBound, vertexBound), simplices, fullOrder);
    result := {};
    targetRank := rank Mat;
    currentRank := 0;
    for i from 0 to (#fullOrder - 1) do (
        if targetRank == #result then break;
        nextSubMtrx := submatrix(Mat, append(result, i));
        if (rank nextSubMtrx) > currentRank then (
            result = append(result, i);
            currentRank = currentRank + 1;
        );
    );
    set apply(result, i -> fullOrder_i)
    );

doc ///
  Key
    exteriorShiftN
  Headline
    compute the exterior shift symbolically using a generic matrix
  Usage
    exteriorShiftN(simplices, fullOrder)
  Description
    Example
      exteriorShiftN({{0,1},{0,2},{1,2}}, LexOrder(3,2))
///

-- Symbolic lex shift (see exteriorShiftN).
extShiftLexN = simplices ->
    if #simplices == 0 then set {} else (
        if not allEqLengths simplices then error "simplices must all be same dimension";
        vertexBound := 1 + max flatten simplices;
        simplexDim := #(simplices_0);
        lexOrd := LexOrder(vertexBound, simplexDim);
        exteriorShiftN(simplices, lexOrd)
    );

doc ///
  Key
    extShiftLexN
  Headline
    compute the exterior shift under the lex order using a generic matrix
  Usage
    extShiftLexN simplices
  Description
    Example
      extShiftLexN {{1,2},{1,3},{2,3}}
///

-- Symbolic reverse-lex shift (see exteriorShiftN).
extShiftRevLexN = simplices ->
    if #simplices == 0 then set {} else (
        if not allEqLengths simplices then error "simplices must all be same dimension";
        vertexBound := 1 + max flatten simplices;
        simplexDim := #(simplices_0);
        revlexOrd := RevLexOrder(vertexBound, simplexDim);
        exteriorShiftN(simplices, revlexOrd)
    );

doc ///
  Key
    extShiftRevLexN
  Headline
    compute the exterior shift under the reverse-lex order using a generic matrix
  Usage
    extShiftRevLexN simplices
  Description
    Example
      extShiftRevLexN {{1,2},{1,3},{2,3}}
///

-- Returns the final (last in lex order) edge of the exterior shift of a triangulation's edges.
-- Used as the convergence witness in the iterative analysis.
finalEdgeOfShift = cplx -> (extShiftLex getEdges cplx)_-1;

doc ///
  Key
    finalEdgeOfShift
  Headline
    return the last edge (in lex order) of the exterior shift of a triangulation
  Usage
    finalEdgeOfShift cplx
  Description
    Example
      finalEdgeOfShift {{1,2,3},{1,3,4},{1,2,4},{2,3,4}}
///

-- isShifted helper: a simplicial complex (1-indexed vertices) satisfies the shifted
-- property if for every face and every vertex i in that face, replacing i with any
-- smaller vertex j not in the face yields another face of the complex.
-- Used in the TEST blocks below; defined here so both blocks can reference it.
isShiftedCplx = cplxFaces -> all(cplxFaces, face -> all(face, i ->
    all(select(toList(1..(i-1)), j -> not member(j, face)), j ->
        member(sort join(delete(i, face), {j}), cplxFaces))));

TEST ///
  -- normalize: convert a 1-indexed shift result back to 0-indexed so that
  -- re-applying extShiftLex uses the same vertex set (idempotency requires this).
  normalize := S -> (toList S) / (face -> face / (v -> v - 1));

  -- Idempotency of extShiftLex: the exterior shift of an already-shifted complex
  -- is the complex itself (fixed-point property), regardless of the random matrix.
  -- Edges (1-simplices)
  S1 := extShiftLex {{0,1},{0,2},{1,2}};
  assert(extShiftLex(normalize S1) == S1)
  S2 := extShiftLex {{0,1},{0,2},{0,3},{1,2},{1,3}};
  assert(extShiftLex(normalize S2) == S2)
  -- Triangles (2-simplices)
  S3 := extShiftLex {{0,1,2},{0,1,3},{0,2,3},{1,2,3}};
  assert(extShiftLex(normalize S3) == S3)

  -- Shiftedness of extShiftLex output: exterior shifting always produces a shifted complex.
  assert(isShiftedCplx extShiftLex {{0,1},{0,2},{1,2}})
  assert(isShiftedCplx extShiftLex {{0,1},{0,2},{0,3},{1,2},{1,3}})
  assert(isShiftedCplx extShiftLex {{0,1,2},{0,1,3},{0,2,3},{1,2,3}})
///

TEST ///
  normalize := S -> (toList S) / (face -> face / (v -> v - 1));

  -- Idempotency of extShiftRevLex.
  S1 := extShiftRevLex {{0,1},{0,2},{1,2}};
  assert(extShiftRevLex(normalize S1) == S1)
  S2 := extShiftRevLex {{0,1},{0,2},{0,3},{1,2},{1,3}};
  assert(extShiftRevLex(normalize S2) == S2)
  S3 := extShiftRevLex {{0,1,2},{0,1,3},{0,2,3},{1,2,3}};
  assert(extShiftRevLex(normalize S3) == S3)

  -- Shiftedness of extShiftRevLex output: exterior shifting produces shifted complexes
  -- regardless of whether lex or rev-lex order is used for the shift itself.
  assert(isShiftedCplx extShiftRevLex {{0,1},{0,2},{1,2}})
  assert(isShiftedCplx extShiftRevLex {{0,1},{0,2},{0,3},{1,2},{1,3}})
  assert(isShiftedCplx extShiftRevLex {{0,1,2},{0,1,3},{0,2,3},{1,2,3}})
///
