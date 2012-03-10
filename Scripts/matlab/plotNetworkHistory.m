%
%  playNetworkHistory.m
%  SMI
%
%  Created by Bedeho Mender on 15/11/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%

function plotNetworkHistory(filename, depth, maxEpoch)

    % Get dimensions
    [networkDimensions, nrOfPresentLayers, historyDimensions] = getHistoryDimensions(filename);
    
    % Setup vars
    numRegions = length(networkDimensions);
    activity = cell(numRegions - 1, 1);
    
    % Fill in missing arguments
    if nargin < 3,
        maxEpoch = historyDimensions.numEpochs;           % pick all epochs
        
        if nargin < 2,
            depth = 1;                                    % pick top layer by default
        end
    end
    
    % Get history array 0;
    for r=2:numRegions,
        if networkDimensions(r).isPresent,
            activity{r-1} = regionHistory(filename, r, depth, maxEpoch);
        end
    end
    
    % Plot
    for e=1:maxEpoch,
        for o=1:historyDimensions.numObjects,
            
            fig = figure();
            title(['Epoch: ' num2str(e) ', Object:' num2str(o)]);
            plotCounter = 1;

            for r=2:numRegions,
                
                y_dimension = networkDimensions(r).y_dimension;
                x_dimension = networkDimensions(r).x_dimension;
                isPresent   = neetworkDimensions(r).isPresent;
                
                if isPresent,
                    for ti=1:historyDimensions.numOutputsPrObject,

                        subplot(nrOfPresentLayers, historyDimensions.numOutputsPrObject, plotCounter);

                        a = activity{r-1}(ti, o, e, :, :);
                        imagesc(reshape(a, [y_dimension x_dimension]));
                        axis square;
                        colorbar
                        hold on;

                        plotCounter = plotCounter + 1;
                    end
                end
            end

            makeFigureFullScreen(fig);
            pause

        end
    end