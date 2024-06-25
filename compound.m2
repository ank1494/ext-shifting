allEqLengths = lst -> (lengths := apply(lst, i -> #i); min lengths == max lengths)
minor = (M,cols,rows) -> det submatrix(M,cols,rows)
compound = (M, rows, cols) -> if not allEqLengths join (rows, cols) then error "not all indices equal in length" else (
      --Mut = mutableMatrix(ring M, #rows, #cols); 
      calcedRows := {};
      for i from 0 to #rows - 1 do (
		newrow := {};
          for j from 0 to #cols - 1 do (
			newrow  = append(newrow, minor(M, rows_i, cols_j)); 
	      );
	  calcedRows = append(calcedRows, newrow);
	  );
      matrix (ring M, calcedRows)
);
  
