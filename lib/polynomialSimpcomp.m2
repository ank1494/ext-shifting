-- Converts a list of facets (given as vertex index lists) into a Macaulay2 SimplicialComplex
-- over QQ, with variables x_v for each vertex v.
getSimpComp = facets -> (
	R = QQ[(reverse getVertices facets) / (i -> x_i)];
	simplicialComplex ((facets) / (f -> facetToMonomial f))
);

doc ///
  Key
    getSimpComp
  Headline
    convert a list of facets to a Macaulay2 SimplicialComplex
  Usage
    getSimpComp facets
  Example
    getSimpComp {{1,2,3},{1,3,4}}
///

-- Converts a single facet (vertex index list) to the corresponding squarefree monomial in R.
-- R must be set before calling (getSimpComp sets it).
facetToMonomial = facet -> (
	result := 1_R;
	for i from 0 to #facet - 1 do result = result * x_(facet_i);
	result
);

doc ///
  Key
    facetToMonomial
  Headline
    convert a facet to its squarefree monomial in the current ring R
  Usage
    facetToMonomial facet
  Example
    getSimpComp {{1,2,3}}; facetToMonomial {1,2,3}
///
