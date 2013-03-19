%
%  regionDataPrEyePositionFASTLOADER.m
%  SMI
%
%  Created by Bedeho Mender on 13/03/13.
%  Copyright 2013 OFTNAI. All rights reserved.
%
%  Purpose: buffer load firing rate file when it is huge
% 

function data =  regionDataPrEyePositionFASTLOADER(experimentPath)

    matFile = [experimentPath '/regionDataPrEyePosition.mat'];
    if(exist(matFile, 'file')),
        
        disp('FAST: Loading .MAT file');
        q = load(matFile, 'data');
        data = q.data;
    else
        
        disp('SLOW: Loading firing rate file, and making .MAT file');
        [data, objectsPrEyePosition] = regionDataPrEyePosition([experimentPath '/firingRate.dat'], numEyePositions);
        save(matFile, 'data');
    end
    
    data = squeeze(data);
    
end