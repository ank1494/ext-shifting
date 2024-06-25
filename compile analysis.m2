exceptionOutputFile = "analysis of critical triangulations with 10 vertices/Exceptions Log 56 tens.txt" << "";
logOutputFile = "analysis of critical triangulations with 10 vertices/Analysis Log 56 tens.txt" << "";
exceptionalCplxOutputFile = "analysis of critical triangulations with 10 vertices/exceptions 56 tens.txt" << "";
elevensOutputFile = "analysis of critical triangulations with 10 vertices/elevens to analyze.txt" << "";

for i from 1 to 10 do (
exceptionFile = concatenate("analysis of critical triangulations with 10 vertices/Exceptions Log 56 part ", toString i, ".txt");
logFile = concatenate("analysis of critical triangulations with 10 vertices/Analysis Log 56 part ", toString i, ".txt");
exceptionalCplxFile = concatenate("analysis of critical triangulations with 10 vertices/exceptions 56 part ", toString i, ".txt");
elevensFile = concatenate("analysis of critical triangulations with 10 vertices/elevens to analyze 56 part ", toString i, ".txt");

exceptionOutputFile << get exceptionFile;
logOutputFile << get logFile;
exceptionalCplxOutputFile << get exceptionalCplxFile;
elevensOutputFile << get elevensFile;
);

exceptionOutputFile << close;
logOutputFile << close;
exceptionalCplxOutputFile << close;
elevensOutputFile << close;