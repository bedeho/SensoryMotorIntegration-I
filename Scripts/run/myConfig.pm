	
	
	#
	#  myConfig.pm
	#  SMI
	#
	#  Created by Bedeho Mender on 21/11/11.
	#  Copyright 2011 OFTNAI. All rights reserved.
	#
	
	package myConfig;
	
	use strict;
	use warnings FATAL => 'all';
	use base qw(Exporter);
	
	our @EXPORT = qw($BASE $PERL_RUN_SCRIPT $PROGRAM $MATLAB_SCRIPT_FOLDER $MATLAB $BINARY LOCAL_RUN XGIRD_RUN DISCRETE CONTINOUS TRACE HEBB NONE COMP SOM HEAP FULL_CONNECTIVITY SPARSE_CONNECTIVITY SPARSE_BIASED NO_HISTORY ALL NO_SYNAPSE SINGLE_CELLS);
	
	our $BASE = "/Network/Servers/mac0.cns.ox.ac.uk/Volumes/Data/Users/mender/Dphil/Projects/SMI/";  # must have trailing slash, "D:/Oxford/Work/Projects/"
	
	################################################################################################################################################################################################
	# Don't touch
	################################################################################################################################################################################################
	
	our $PERL_RUN_SCRIPT 		= $BASE."Scripts/run/Run.pl";
	our $PROGRAM				= $BASE."Source/DerivedData/SMI/Build/Products/Release/SMI";
	our $MATLAB_SCRIPT_FOLDER 	= $BASE."Scripts/matlab/";  # must have trailing slash
	our $MATLAB 				= "/Volumes/Apps/MATLAB_R2011b.app/bin/matlab -nosplash -nodisplay"; # -nodesktop
	our $BINARY					= "SMI";
	
	# $xgrid
	use constant LOCAL_RUN => 0;
	use constant XGIRD_RUN => 1;
	
	# $neuronType
	use constant DISCRETE => 0;
	use constant CONTINOUS => 1;
	
	# $learningRule
	use constant TRACE => 0;
	use constant HEBB => 1;
	
	# $lateralInteraction
	use constant NONE => 0;
	use constant COMP => 1;
	use constant SOM => 2;
	
	# $sparsenessRoutine
	use constant HEAP => 1;
	
	# Connectivity
	use constant FULL_CONNECTIVITY => 0;
	use constant SPARSE_CONNECTIVITY => 1;
	use constant SPARSE_BIASED => 2;
	
	# saveHistory
	use constant NO_HISTORY => 0;
	use constant ALL => 1;
	use constant NO_SYNAPSE => 2;
	use constant SINGLE_CELLS => 3; 

	1;