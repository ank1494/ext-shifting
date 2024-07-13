# ext-shifting
Macaulay2 code for exterior shifting, and analyzing the shiftings of surfaces.

Comments, questions, suggestions, corrections etc. are welcome at aaron.keehn@mail.huj.ac.il

## How to run the calculations for the shifting of the edges
1. In the file 'analysis config.m2', set the name of the analysis you want to run in the 'analysisName' field (this can be anything you want, as long as it is a valid directory name), and set the 'analysisInputFile' field to the path of the initial input file (you can uncomment to use one of the provided input files for analyzing the torus, klein bottle or projective plane).
2. Open Macaulay2 in the directory of the cloned repository (ext-shifting)
3. run the command: 'load "analyze triangs.m2"'. Repeat for multiple iterations until the message "no more splits to calculate" appears.
4. You can view the outputs in the directory 'analysis output/<analysisName>'. In the 'iteration_<n>' folders you can find the summary files, which summarize the findings of each iteration

## Functions to know

Hope to polish a bit in the near future. there are a few cases in the analysis of the Klein bottle that aren't caught and I need to take care of.
