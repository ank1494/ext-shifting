-- Recursive helpers for generating total orders on simplices.
-- LexOrder produces simplices in lexicographic order; RevLexOrder in reverse-lexicographic order.
-- Both enumerate all simplexDim-element subsets of {0, ..., vertexBound-1}.

recursiveRevLex = (vertexBound,simplexDim) -> if simplexDim == 0 then {{}} else if vertexBound-simplexDim == 0 then {toList (0..vertexBound-1)} else join(recursiveRevLex(vertexBound-1,simplexDim), apply(recursiveRevLex(vertexBound-1,simplexDim-1), partialSimplex->append(partialSimplex,vertexBound-1)))
recursiveLex = (startIndex,vertexBound,simplexDim) -> if simplexDim == 0 then {{}} else if startIndex + simplexDim == vertexBound then {toList (startIndex..vertexBound-1)} else join(apply(recursiveLex(startIndex+1,vertexBound,simplexDim-1), partialSimplex-> prepend(startIndex,partialSimplex)), recursiveLex(startIndex+1,vertexBound,simplexDim))

-- All simplexDim-subsets of {0..vertexBound-1} in lexicographic order.
LexOrder = (vertexBound,simplexDim) -> recursiveLex(0,vertexBound,simplexDim)

-- All simplexDim-subsets of {0..vertexBound-1} in reverse-lexicographic order.
RevLexOrder = (vertexBound,simplexDim) -> recursiveRevLex(vertexBound,simplexDim)

doc ///
  Key
    LexOrder
  Headline
    generate all simplices of a given dimension in lexicographic order
  Usage
    LexOrder(vertexBound, simplexDim)
  Description
    Example
      LexOrder(4, 2)
///

doc ///
  Key
    RevLexOrder
  Headline
    generate all simplices of a given dimension in reverse-lexicographic order
  Usage
    RevLexOrder(vertexBound, simplexDim)
  Description
    Example
      RevLexOrder(4, 2)
///
