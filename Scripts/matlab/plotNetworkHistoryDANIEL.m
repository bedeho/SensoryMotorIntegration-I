%
%  plotNetworkHistoryDANIEL.m
%  SMI
%
%  Created by Bedeho Mender on 17/02/12.
%  Copyright 2012 OFTNAI. All rights reserved.
%

function plotNetworkHistoryDANIEL(filename, region, depth, maxEpoch)

    % Get dimensions
    [networkDimensions, nrOfPresentLayers, historyDimensions] = getHistoryDimensions(filename);
    
    % Setup vars
    numRegions = length(networkDimensions);
    
    % Fill in missing arguments
    if nargin < 4,
        maxEpoch = historyDimensions.numEpochs;           % pick all epochs
        
        if nargin < 3,
            depth = 1;                                    % pick top layer by default
            
            if nargin < 2,
                region = numRegions;
            end
        
        end
    end
    
    % Get history array
    %for r=2:numRegions,
    %    activity{r-1} = regionHistory(filename, r, depth, maxEpoch);
    %end
    activity = regionHistory(filename, region, depth, maxEpoch);
    
    y_dimension = networkDimensions(region).y_dimension;
    x_dimension = networkDimensions(region).x_dimension;
    
    nrOfCells = x_dimension * y_dimension;
    dataPointsPerCell = historyDimensions.epochSize;
    
    % Plot
    for e=1:maxEpoch,
        
        fig = figure();
        title(['Epoch: ' num2str(e)]);

        tmp = activity(:, :, e, :, :);
        tmp = reshape(tmp, [dataPointsPerCell nrOfCells]);
        tmp = tmp'; % (cells,time)
        
        imagesc(tmp);
        colorbar

        %makeFigureFullScreen(fig);
        pause

    end