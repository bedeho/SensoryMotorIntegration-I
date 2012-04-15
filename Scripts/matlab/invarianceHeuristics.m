%
%  invarianceHeuristics.m
%  SMI
%
%  Created by Bedeho Mender on 20/02/12.
%  Copyright 2012 OFTNAI. All rights reserved.
%
%  Purpose: Make heuristic analysis of info analysis

function responseCounts = invarianceHeuristics(filename, nrOfEyePositionsInTesting)

    % Get dimensions
    [networkDimensions, nrOfPresentLayers, historyDimensions] = getHistoryDimensions(filename);
    
    % Load data
    [data, objectsPrEyePosition] = regionDataPrEyePosition(filename, nrOfEyePositionsInTesting); % (object, eye_position, row, col, region)
    
    % Region
    r = length(networkDimensions);
    
    % Get dimensions for this region
    y_dimension = networkDimensions(r).y_dimension;
    x_dimension = networkDimensions(r).x_dimension;
    
    % Process data
    v0 = data{r-1};
    v0(v0 > 0) = 1;  % count all nonzero as 1, error terms have already been removed
    
    %% Do special case for one transform in Simon mode!!!
    if objectsPrEyePosition> 1,
        responsePerObject = squeeze(sum(v0)); % (eye_position, row, col)
    else
        responsePerObject = squeeze(v0); % (eye_position, row, col)
    end
    
    %%

    % Clear out cells that respond to multiple objects
    % Note: Couldnt figure it out in vectorized form.
    numberOfObjectsRespondedTo = squeeze(sum(responsePerObject > 0)); % (row,col) = number of objects responded to atleast one transform of
    respondedToMultiple = numberOfObjectsRespondedTo > 1; % (row,col) = true/false: responded to multiple objects

    % Clear out cells that respond to more than one object
    for row=1:y_dimension,
        for col=1:x_dimension,
            responsePerObject(:,row,col) = ~respondedToMultiple(row,col) * responsePerObject(:,row,col); % Zero out cells that responded to multiple
        end
    end
    
    % Put into format for bar plotting
    responseCounts = zeros(nrOfEyePositionsInTesting, objectsPrEyePosition);
    
    % Plot a line for each object
    for e=1:nrOfEyePositionsInTesting,
        z = responsePerObject(e,:,:);
        z = z(:);
        z(z == 0) = [];
        responseCounts(e, :) = hist(z,1:objectsPrEyePosition);
    end

    
    
end

%% OLD LINE PLOT STYLE
%{
function responseCounts = invarianceHeuristics(filename, nrOfEyePositionsInTesting)

    % Get dimensions
    [networkDimensions, nrOfPresentLayers, historyDimensions] = getHistoryDimensions(filename);
    
    % Load data
    [data, objectsPrEyePosition] = regionDataPrEyePosition(filename, nrOfEyePositionsInTesting); % (object, eye_position, row, col, region)
    
    % Region
    r = length(networkDimensions);
    
    % Get dimensions for this region
    y_dimension = networkDimensions(r).y_dimension;
    x_dimension = networkDimensions(r).x_dimension;
    
    % Process data
    v0 = data{r-1};
    v0(v0 > 0) = 1;  % count all nonzero as 1, error terms have already been removed
    
    %% Do special case for one transform in Simon mode!!!
    if objectsPrEyePosition> 1,
        responsePerObject = squeeze(sum(v0)); % (eye_position, row, col)
    else
        responsePerObject = squeeze(v0); % (eye_position, row, col)
    end
    
    %%

    % Clear out cells that respond to multiple objects
    % Note: Couldnt figure it out in vectorized form.
    numberOfObjectsRespondedTo = squeeze(sum(responsePerObject > 0)); % (row,col) = number of objects responded to atleast one transform of
    respondedToMultiple = numberOfObjectsRespondedTo > 1; % (row,col) = true/false: responded to multiple objects

    % Clear out cells that respond to more than one object
    for row=1:y_dimension,
        for col=1:x_dimension,
            responsePerObject(:,row,col) = ~respondedToMultiple(row,col) * responsePerObject(:,row,col); % Zero out cells that responded to multiple
        end
    end
    
    responseCounts = cell(nrOfEyePositionsInTesting,1);
    
    % Plot a line for each object
    for e=1:nrOfEyePositionsInTesting,
        z = responsePerObject(e,:,:);
        z = z(:);
        z(z == 0) = [];
        responseCounts{e} = hist(z,1:objectsPrEyePosition);
    end

end
%}

