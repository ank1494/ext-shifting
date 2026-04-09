# ext-shifting
Macaulay2 code for exterior shifting and analyzing the shiftings of surfaces.

Comments, questions, suggestions, corrections etc. are welcome at aaron.keehn@mail.huj.ac.il

## How to load the libraries

```
load "libs.m2"
```

## How to shift a simplicial complex

Pass a list of same-dimension simplices. For example, to shift a graph:

```
extShiftLex {{1,2},{1,3},{3,4}}
```

To shift the edges of a full triangulation, extract the 1-skeleton first:

```
extShiftLex getEdges myTriangulation
```

## How to run the iterative analysis

The queue-based analysis stores each pending triangulation as its own file, so it survives interruption and can be resumed at any time.

### Worked example — irreducible tori

1. Create a config file (e.g. `my_config.m2`):

   ```
   analysisName = "tori-analysis"
   analysisInputFile = "/absolute/path/to/data/surface triangulations/irredTori.m2"
   analysisOutputDir = "/absolute/path/to/analysis output/tori-analysis"
   ```

2. Run the queue orchestrator from the root of the cloned repository:

   ```
   M2 --script scripts/runQueue.m2 /absolute/path/to/my_config.m2
   ```

   The script processes triangulations one at a time, printing structured lifecycle events (`EVENT:{...}`) alongside raw M2 output, until the queue is empty (convergence).

3. Results are written to `analysis output/<analysisName>/`. Processed items accumulate in `done/` and unprocessed items remain in `pending/`.

### Resuming a paused run

Run the same command again — `initQueueEnv.m2` detects the existing `pending/` directory and skips re-seeding, so the run continues from where it left off:

```
M2 --script scripts/runQueue.m2 /absolute/path/to/my_config.m2
```

### Batch caps

Pass optional caps as positional arguments after the config path (use `null` to skip a cap):

```
M2 --script scripts/runQueue.m2 /absolute/path/to/my_config.m2 <itemCap> <maxVertexCount> <timeoutSeconds>
```

| Argument | Effect |
|---|---|
| `itemCap` | Stop after processing this many triangulations |
| `maxVertexCount` | Stop before processing a triangulation with more vertices than this |
| `timeoutSeconds` | Stop after this many wall-clock seconds (never mid-item) |

Example — process at most 10 items, no other caps:

```
M2 --script scripts/runQueue.m2 /absolute/path/to/my_config.m2 10 null null
```

The script emits `EVENT:{"type":"run_paused"}` when a cap stops the run, or `EVENT:{"type":"run_complete"}` when the queue empties naturally.

## Functions to know

All functions below are available after `load "libs.m2"`.

### Exterior shifting

| Function | Description |
|---|---|
| `extShiftLex simplices` | Exterior shift of a simplex list under the lex order (randomized matrix, fast) |
| `extShiftRevLex simplices` | Exterior shift under the reverse-lex order |
| `finalEdgeOfShift cplx` | The final (lex-largest) edge of the exterior shift of `cplx`'s 1-skeleton |

`simplices` is a list of same-dimension faces, e.g. `{{1,2},{1,3},{2,3}}`. Vertices must be non-negative integers.

### Combinatorial helpers

| Function | Description |
|---|---|
| `getVertices cplx` | List of all vertices in `cplx` |
| `getEdges cplx` | List of all edges (1-faces) of `cplx` |
| `getBoundaryEdges surface` | Edges appearing in exactly one triangle (boundary of a surface with boundary) |
| `kSkeleton(cplx, k)` | All k-dimensional faces of `cplx` |
| `eulerCharSrfc surface` | Euler characteristic of a triangulated surface (triangles only) |
| `isConnected cplx` | Whether `cplx` is connected |
| `is4prime complex` | Whether no two degree-4 vertices are adjacent |

### Vertex splits

| Function | Description |
|---|---|
| `nonTrivSplits complex` | All non-trivial vertex splits of a triangulation; returns a list of `{splitComplex, splitData}` pairs |

### Analysis

| Function | Description |
|---|---|
| `getCritRegions(complex, finalEdge)` | Identifies critical regions and vertex splits to pass to the next iteration; returns a `CritRegionsResult` |
| `getCritRegions(complex, finalEdge, exemptSplits => splits)` | Same, but first filters `splits` (a list of `{base, neighbors}` pairs) from the non-trivial split enumeration |
| `analyzeIteration triangulations` | Pure mathematical core of one analysis iteration: takes a list of triangulations, returns `(foundCritRegions, splitsForNextCalc, largestNonPrefixVertices)` |
| `analyzeIteration(triangulations, exemptions => table)` | Same, but `table` is a `HashTable` mapping triangulations to their exempt split lists (see `kbExemptSplits.m2`) |

## Klein bottle split exemptions

Three vertex splits on `irredKb_25` (a 10-vertex Klein bottle formed by connected sum of two irreducible RP² triangulations at vertices 0, 1, 2) are topologically equivalent to a trivial split on one RP² component before gluing. The `nonTrivialVertexSplits` filter cannot detect this because the connected sum hides the triviality.

The file `data/surface triangulations/kbExemptSplits.m2` defines a `HashTable` mapping `irredKb_25` to these three exempt splits (`{0,{1,2}}`, `{1,{0,2}}`, `{2,{0,1}}`). The analysis script (`runAnalysis.m2`) loads this file and passes it to `analyzeIteration`, suppressing the false-positive exceptions.
