load "lib/graphs.m2"
load "lib/utils.m2"
load "lib/lex.m2"
load "lib/randomMatrix.m2"
load "lib/compound.m2"
load "lib/exteriorShifting.m2"
load "lib/partial.m2"
load "lib/vertexSplit.m2"
--load "analyze splits.m2"
load "lib/criticalRegions.m2"
load "lib/polynomialSimpcomp.m2"

-- increment all vertex indices by 1 (converts 0-indexed to 1-indexed)
bump = tbl -> applyTable(tbl, x -> x + 1);
