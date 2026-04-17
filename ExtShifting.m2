newPackage("ExtShifting",
    Version => "0.1",
    Authors => {{Name => "Aaron Keehn", Email => "aaron.keehn@mail.huj.ac.il"}},
    Headline => "Exterior shifting computations for simplicial complexes",
    PackageExports => {"SimplicialComplexes"},
    DebuggingMode => false
)

-- currentFileDirectory is correct here (inside the package body).
-- Capture it now; it returns "./" in the documentation section.
pkgSrcDir := currentFileDirectory;

export {
    -- utils.m2
    "allNonegInts", "incrementVertices", "swap", "swapTable", "kSkeleton",
    "getEdges", "getVertices", "getBoundaryEdges", "eulerCharSrfc",
    "hasNoAdjacentDegree4Vertices", "isConnected", "isCycle", "isPinchedDiskBdry",
    "degreeOfVertex", "numberOfVerticesWithDegree",
    "findEdgeMissingTriangles", "findEdgesWithOneMissingTriangle",
    "vertexLink",
    -- graphs.m2
    "completeBipartiteEdges",
    -- lex.m2
    "recursiveRevLex", "recursiveLex", "LexOrder", "RevLexOrder",
    -- randomMatrix.m2
    "randomMatrix",
    -- compound.m2
    "allEqLengths", "minor", "compound",
    -- exteriorShifting.m2
    "validateForExtShift", "exteriorShift", "extShiftLex", "extShiftRevLex",
    "exteriorShiftN", "extShiftLexN", "extShiftRevLexN", "finalEdgeOfShift",
    "isShiftedCplx",
    -- partial.m2
    "isPartialLeq", "elementsPartialLessThan", "partialShift",
    -- vertexSplit.m2
    "VertexSplitData", "allSplitsAtVertex0", "nonTrivialSplitsAtVertex0",
    "nonTrivialVertexSplits",
    -- criticalRegions.m2
    "ShiftAnnotatedSplit", "CritRegionsResult",
    "isSameSideSplit", "getCritRegions",
    "exemptSplits",
    -- HashTable key symbols for VertexSplitData fields
    "base", "neighbors", "ratio",
    -- HashTable key symbols for ShiftAnnotatedSplit fields
    "splitData", "preservesFinalEdge", "noVertex4",
    -- HashTable key symbols for CritRegionsResult fields
    "critRegions", "nextSplits",
    -- polynomialSimpcomp.m2
    "getSimpComp", "facetToMonomial",
    -- analyzeIteration.m2
    "analyzeIteration",
    -- queueOps.m2
    "queueSeqStr", "writeQueueItem", "readQueueItem", "nextQueueSeq",
    "emitRunPaused", "emitRunComplete", "runQueue",
    "emitItemStarted", "emitItemDone", "processQueueItem", "initQueue",
    "writeDoneItem", "critRegionToJson", "critRegionsToJson",
    "itemCap", "maxVertexCount", "timeoutSeconds", "exemptions",
    "splitFrom",
    -- logging stubs
    "logInfo", "logException"
}

-- Pre-assign package-internal mutable symbols so the package check
-- does not flag them as "mutable unexported unset".
result = null;
complex = null;        -- HashTable key in ShiftAnnotatedSplit; not exported to
                       -- avoid shadowing M2's built-in chain-complex function
splitInfoString = null;
splitInfoList = null;
R = null;              -- shared ring state between getSimpComp / facetToMonomial
protect x;             -- ring variable base; single-letter, cannot be exported

-- Stub doc so lib files can be loaded before beginDocumentation().
-- doc /// blocks in lib/ are silently skipped; TEST /// blocks are
-- registered normally by M2's TEST function which is always available.
doc = s -> null;

needs (pkgSrcDir | "lib/graphs.m2")
needs (pkgSrcDir | "lib/utils.m2")
needs (pkgSrcDir | "lib/lex.m2")
needs (pkgSrcDir | "lib/randomMatrix.m2")
needs (pkgSrcDir | "lib/compound.m2")
needs (pkgSrcDir | "lib/exteriorShifting.m2")
needs (pkgSrcDir | "lib/partial.m2")
needs (pkgSrcDir | "lib/vertexSplit.m2")
needs (pkgSrcDir | "lib/criticalRegions.m2")
needs (pkgSrcDir | "lib/polynomialSimpcomp.m2")
needs (pkgSrcDir | "lib/analyzeIteration.m2")
needs (pkgSrcDir | "lib/queueOps.m2")

-- Default no-op logging stubs. The analysis runtime overrides these
-- with file-writing implementations.
logInfo = msg -> null;
logException = (cplx, msg) -> null;

-- Tests in lib/ use relative paths like "data/...".  M2's check runner
-- cd's to a temp directory for each test subprocess.  Create a symlink
-- so those paths resolve correctly regardless of CWD.
if not isDirectory "data" then
    run ("ln -sf \"" | pkgSrcDir | "data\" data 2>/dev/null");
if not isDirectory "scripts" then
    run ("ln -sf \"" | pkgSrcDir | "scripts\" scripts 2>/dev/null")

beginDocumentation()
