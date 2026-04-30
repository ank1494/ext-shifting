# ext-shifting
Macaulay2 code for exterior shifting and analyzing the shiftings of surfaces.

Comments, questions, suggestions, corrections etc. are welcome at aaron.keehn@mail.huj.ac.il

## Installation

Clone the repository, then run in an M2 session (replacing the path with your actual clone location):

```
installPackage("ExtShifting", FileName => "/path/to/ext-shifting/ExtShifting.m2")
```

After installation, load with `loadPackage "ExtShifting"`. All lib functions and `SimplicialComplexes` are available automatically.

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
| `vertexLink(cplx, v)` | Link of vertex `v` in a 2-dimensional complex: all faces containing `v`, with `v` removed |
| `isConnected cplx` | Whether `cplx` is connected |
| `is4prime complex` | Whether no two degree-4 vertices are adjacent |

### Vertex splits

| Function | Description |
|---|---|
| `nonTrivSplits complex` | All non-trivial vertex splits of a triangulation; returns a list of `{splitComplex, splitData}` pairs |

### Permutation algebra

Used for automorphism verification and exemption checking. Permutations are index-based lists: position `i` holds the image of vertex `i`.

| Function | Description |
|---|---|
| `applyPermutation(perm, complex)` | Relabels every vertex in every face by `perm`; returns the canonically sorted complex |
| `isAutomorphism(perm, complex)` | True iff `applyPermutation(perm, complex) === canonical complex` |
| `groupClosure generators` | BFS expansion: returns all group elements reachable from `generators`, including the identity |
| `applyPermutationToSplit(perm, split)` | Maps `{base, {n1,n2}}` to `{perm#base, sort {perm#n1, perm#n2}}` |
| `isExemptionValid(complex, generators, exemptSplits, allSplits)` | For each exempt split, checks that at least one orbit partner is non-exempt. Returns violating splits — empty means valid. |

### Analysis

| Function | Description |
|---|---|
| `getCritRegions(complex, finalEdge)` | Identifies critical regions and vertex splits to pass to the next iteration; returns a `CritRegionsResult` |
| `getCritRegions(complex, finalEdge, exemptSplits => splits)` | Same, but first filters `splits` (a list of `{base, neighbors}` pairs) from the non-trivial split enumeration |
| `analyzeIteration triangulations` | Pure mathematical core of one analysis iteration: takes a list of triangulations, returns `(foundCritRegions, splitsForNextCalc, largestNonPrefixVertices)` |
| `analyzeIteration(triangulations, exemptions => table)` | Same, but `table` is a `HashTable` mapping triangulations to their exempt split lists (see `kbExemptSplits.m2`) |

## Automorphism data

Automorphism group generators for each analysed triangulation are stored in:

- `data/surface triangulations/kbAutomorphisms.m2` — Klein bottle triangulations (`irredKb_0`–`irredKb_4`, `irredKb_25`)
- `data/surface triangulations/toriAutomorphisms.m2` — torus triangulations (`irredTori_0`–`irredTori_4`)

Each file is a `HashTable` mapping a triangulation to a list of generator permutations (index-based: position `i` holds the image of vertex `i`). Cycle-notation comments above each generator aid human verification. The full automorphism group is computed at analysis time by `groupClosure`.

Automorphism verification tests are in `tests/automorphisms-kb.m2` and `tests/automorphisms-tori.m2`. For each triangulation they check: (1) group order matches the expected value; (2) every group element is an automorphism; (3) the exemption table has no violations (`isExemptionValid` returns empty); (4) every non-exempt split at an automorphism-covered base is the lex-minimum of its orbit.

## Split exemptions

The exemption tables in `data/surface triangulations/kbExemptSplits.m2` and `toriExemptSplits.m2` list non-trivial vertex splits that are excluded from the critical region analysis. Two kinds of exemption exist:

**Automorphism-based:** Splits in the same automorphism orbit as a retained lex-minimum representative are omitted to avoid redundant computation. This accounts for the vast majority of entries in both files. For example, `irredTori_0` has a transitive automorphism group of order 42, so only 2 splits need to be computed rather than all 63.

**Topology-based (irredKb_25 only):** Three splits on the 10-vertex Klein bottle `irredKb_25` — `{0,{1,2}}`, `{1,{0,2}}`, `{2,{0,1}}` — are topologically equivalent to a trivial split on one RP² component of the connected sum. The `nonTrivialVertexSplits` filter cannot detect this because the connected sum hides the triviality, causing false-positive "bad split" exceptions. `{1,{0,2}}` and `{2,{0,1}}` are also covered by automorphism exemptions; `{0,{1,2}}` is the automorphism representative but is still a false positive, so it is added to the table explicitly.

The analysis script loads the appropriate exemptions file and passes it to `analyzeIteration` to suppress these splits before shift computation.
