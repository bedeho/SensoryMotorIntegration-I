%
%  regionTrace.m
%  SMI
%
%  Created by Bedeho Mender on 06/02/12.
%  Copyright 2012 OFTNAI. All rights reserved.
%

function [MeanObjects, MeanTransforms] = regionTrace(filename, nrOfEyePositionsInTesting)

    % Get dimensions
    [networkDimensions, historyDimensions] = getHistoryDimensions(filename);
    
    % Load data
    [data, objectsPrEyePosition] = regionDataPrEyePosition(filename, nrOfEyePositionsInTesting);

    % Pick top region
    r = length(networkDimensions);
    
    % Cleanup so sum() counts instances for us
    dataPrEyePosition = data{r-1,1} > 0; % (object, eye_position, row, col)
    
    % Number of times a given (row,col) cell responds to something
    NrOfResponsesPerCell = squeeze(sum(sum(dataPrEyePosition))); % (row, col)
    
    % Number of cells respoding to atleast one pattern
    totalNrOfResponses = squeeze(sum(sum(NrOfResponsesPerCell)));
    NrOfCellsRespondingToSomething = nnz(NrOfResponsesPerCell > 0); % single number
    
    % MeanTransforms = mean number of patterns responded to among those
    % that respond to something
    MeanTransforms = totalNrOfResponses/NrOfCellsRespondingToSomething
    
    % MeanObjects = mean numer of objects responded to among those that respond to somthing, 
    numberOfObjectsRespondedTo = squeeze(sum(sum(dataPrEyePosition) > 0));% (row,col) = number of objects responded to atleast one transform;
    
    MeanObjects = sum(sum(numberOfObjectsRespondedTo))/NrOfCellsRespondingToSomething;
    
    