
**********
* README *
**********

*********************
* DEPLOYMENT OF SMI *
*********************
1. Make a designated directory <DIR>
2. Make the following directory structure
  <DIR>
	|-Experiments
	|-Results
	|-Scripts
	|-Stimuli
	|-Writing
	|-Xgrid
3. Clone down git@github.com:bedeho/SMI into <DIR> and rename to "Source"
4. Clone down git@github.com:bedeho/SMIMatlabScripts.git into <DIR/Scripts> and rename to "Analysis"
5. Clone down git@github.com:bedeho/SMIRunScripts.git into <DIR/Scripts> and rename to "Run"
datatables.net/extras/tabletools/plug-ins
8. Manually get myConfig.pm and put in "Scripts/Run/myConfig.pm" change $BASE to <DIR>, remember to add trailing slash
9. Manually get declareGlobalVars.m and put in "Scripts/Analysis/declareGlobalVars.m" change variable "base" to <DIR>, and remember to have trailing slash

**********************
* XCODE PROJECT FILE *
**********************
1. Change to 32-bit, because libconfig is 32 bit I think?
2. CHANGE TO RELEASE SETTINS IN TARGET SETTINGS EDITOR AND IN XCODE CODE EDITOR ITSELF: Active Scheme->Edit scheme
3. Change build location: Xcode->Preferences->DerivedData, change to "Relative" and let it be "DerivedData"
4. REMEMBER TO SET MULTIPLE VALUES (common for debug/release) AND set for project and target column simultaneously.
5. Enable OpenMP Support = Yes, alternatively add compiler flag -fopenmp.
6. Always Search User Paths = Yes 
7. Header Search Paths: 
/Network/Servers/mac0.cns.ox.ac.uk/Volumes/Data/Users/mender/GSL/include
/Network/Servers/mac0.cns.ox.ac.uk/Volumes/Data/Users/mender/libconfig/include
8. Library Search Paths: 
/Network/Servers/mac0.cns.ox.ac.uk/Volumes/Data/Users/mender/GSL/lib
/Network/Servers/mac0.cns.ox.ac.uk/Volumes/Data/Users/mender/libconfig/lib
9. Other linker flag:
-lconfig++
-lgsl
-
10. DO NOT LINK DYNIMCALY TO .so or .dynlib (or whatever they call it on macs), then grid fails since there
is no libconfig on there!! actually link GSL statically to, since getting the local version to work was
a total headache!!!

***************
* ADD STIMULI *
***************
1.
2.
3.
4.
5.
	  
	

	
