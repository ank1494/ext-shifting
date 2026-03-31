-- Returns true if every element of lst has the same length.
allEqLengths = lst -> (lengths := apply(lst, i -> #i); min lengths == max lengths)

doc ///
  Key
    allEqLengths
  Headline
    test whether all elements of a list have the same length
  Usage
    allEqLengths lst
  Description
    Example
      allEqLengths {{0,1},{1,2},{2,3}}
///

-- The (rows, cols)-minor of M: determinant of the submatrix with row indices rows and column indices cols.
minor = (M, cols, rows) -> det submatrix(M, cols, rows)

-- Constructs the compound (exterior power) matrix of M with respect to row index sets and column index sets.
-- Entry (i,j) is the minor of M selecting rows rows_i and columns cols_j.
-- rows and cols must be lists of equal-length index tuples (simplex dimension must be consistent).
compound = (M, rows, cols) -> if not allEqLengths join(rows, cols) then error "not all indices equal in length" else (
    calcedRows := {};
    for i from 0 to #rows - 1 do (
        newrow := {};
        for j from 0 to #cols - 1 do (
            newrow = append(newrow, minor(M, rows_i, cols_j));
        );
        calcedRows = append(calcedRows, newrow);
    );
    matrix(ring M, calcedRows)
);

doc ///
  Key
    compound
  Headline
    compute the compound (exterior power) matrix
  Usage
    compound(M, rows, cols)
  Description
    Example
      compound(random(QQ^4,QQ^4), {{0,1},{2,3}}, {{0,1},{0,2},{1,2},{0,3},{1,3},{2,3}})
///
