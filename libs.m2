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
load "lib/analyzeIteration.m2"

-- Default no-op logging stubs. The analysis runtime (runAnalysis.m2) overrides these
-- with file-writing implementations. These stubs ensure library functions work in
-- isolation (e.g. when running TEST blocks without the full analysis environment).
logInfo = msg -> null;
logException = (cplx, msg) -> null;
