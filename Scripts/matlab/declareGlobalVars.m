%
%  delcareGlobalVars.m
%  SMI
%
%  Created by Bedeho Mender on 15/11/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%
%  Purpose: Declare global variables

function declareGlobalVars()

    global base;
	base = '/Network/Servers/mac0.cns.ox.ac.uk/Volumes/Data/Users/mender/Dphil/Projects/SMI/'; % must have trailing slash

    global EXPERIMENTS_FOLDER;
    EXPERIMENTS_FOLDER = [base 'Experiments/'];  

    % Reason added abstraction was because
    % perhaps data is produced on system which
    % has makes C++ binary have different size datatypes then
    % what is default here, if so, change values accordingly.

    % Data type sizes for platform that generated the output files
    global SOURCE_PLATFORM_UINT;
    SOURCE_PLATFORM_UINT = 'uint32';
    
    global SOURCE_PLATFORM_UINT_SIZE;
    SOURCE_PLATFORM_UINT_SIZE = 4;
    
    global SOURCE_PLATFORM_USHORT;
    SOURCE_PLATFORM_USHORT = 'uint16';
    
    global SOURCE_PLATFORM_USHORT_SIZE;
    SOURCE_PLATFORM_USHORT_SIZE = 2;
    
    global SOURCE_PLATFORM_FLOAT;
    SOURCE_PLATFORM_FLOAT = 'float';
    
    global SOURCE_PLATFORM_FLOAT_SIZE;
    SOURCE_PLATFORM_FLOAT_SIZE = 4;
    
    global SYNAPSE_ELEMENT_SIZE;
    SYNAPSE_ELEMENT_SIZE = (4 * SOURCE_PLATFORM_USHORT_SIZE + SOURCE_PLATFORM_FLOAT_SIZE); % region >> depth >> row >> col >> weight
    
    global floatError;
    floatError = 0.05;