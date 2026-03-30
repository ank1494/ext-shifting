needs "utils.m2";

getSimpComp = facets -> (
	R = QQ[(reverse getVertices facets) / (i -> x_i)];
	simplicialComplex ((facets) / (f -> facetToMonomial f))
);

facetToMonomial = facet -> (
	result := 1_R;
	for i from 0 to #facet - 1 do result = result * x_(facet_i);
	result
);