# rat_reunion

Matlab code for the Rat Reunion study, including both isolation-separation and repeat-reunion (relationship formation)

The code is organized in a collection of Matlab livescripts (ratreunion_livescripts) that call supporting functions (ratreunion_supportingfunctions). 

All main livescripts are titled ratreunion_partXX_XXX.mlx

To run, always start with part0, which sets-up the variables, and then use the part that applies to the analysis to be performed.

Index of parts:

part 0: loading and organizing tables/variables
Requires, for example: - ReunionDatabase_Rat - FindFiles.m - ProcessBORIS.m - ... Data files needed: - Spreadsheet with all reunion info - (read directly from Google sheets), eventsXXX.csv files (all of the events files, kept on the local machine)

part 1: Separation-Isolation analyses

part 2: Repeat-reunion (stranger vs. cagemate) analyses
