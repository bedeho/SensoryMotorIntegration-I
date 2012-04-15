
%  plotRegion.m
%  SMI
%
%  Created by Bedeho Mender on 15/11/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%

function [outputPatternsPlot, MeanObjects, MeanTransforms, orthogonalityIndex, regionOrthogonalizationPlot, regionCorrelationPlot, corr, invariancePlot] = plotRegion(filename, info, dotproduct, region, depth)

    % Get dimensions
    [networkDimensions, nrOfPresentLayers, historyDimensions] = getHistoryDimensions(filename);
    
    % Fill in missing arguments    
    if nargin < 5,
        depth = 1;                                  % pick top layer
        
        if nargin < 4,
            region = length(networkDimensions);     % pick last region
        end
    end
    
    if region < 2,
        error('Region is to small');
    end
    
    % Compute region correlation
    corr = regionCorrelation(filename, info.nrOfEyePositionsInTesting);
    
    % Plot region correlation
    regionCorrelationPlot = figure();
    imagesc(corr{region-1});
    colorbar;

    % Multiple indexes
    regionOrthogonalizationPlot = figure();
    
    % Compute orthogonalization
    [outputPatterns, orthogonalityIndex, inputCorrelations, outputCorrelations] = regionOrthogonality(filename, info.nrOfEyePositionsInTesting, dotproduct, region);
        
    scatter(inputCorrelations,outputCorrelations);
    xlabel('Input Correlations');
    ylabel('Output Correlations');
    
    axis([-0.1 1.1 -0.1 1.1]);
    line([0,1],[0,1], 'linewidth',1,'color',[1,0,0]);
    
    % Plot
    outputPatternsPlot = figure();
    imagesc(outputPatterns);
    colorbar;
    
    % Invariance & Selectivity
    [MeanObjects, MeanTransforms] = regionTrace(filename, info.nrOfEyePositionsInTesting);
    
    %% Compute invariance heuristic
    invariancePlot = figure();
    
    responseCounts = invarianceHeuristics(filename, info.nrOfEyePositionsInTesting);

    bar(responseCounts);
    
    %{

    responseCounts = invarianceHeuristics(filename, info.nrOfEyePositionsInTesting);
    markerSpecifiers = {'r+', 'kv', 'bx', 'cs', 'md', 'y^', 'g.', 'w>','r+', 'kv', 'bx', 'cs', 'md', 'y^', 'g.', 'w>', 'r+', 'kv', 'bx', 'cs', 'md', 'y^', 'g.', 'w>','r+', 'kv', 'bx', 'cs', 'md', 'y^', 'g.', 'w>'};
    
    % Plot a line for each object
    for e=1:info.nrOfEyePositionsInTesting,
        plot(responseCounts{e}, ['-' markerSpecifiers{e}], 'Linewidth', 3);
        hold all
    end

    axis tight
    
    % Object legend
    objectLegend = cell(info.nrOfEyePositionsInTesting,1);
    for o=1:info.nrOfEyePositionsInTesting,
        objectLegend{o} = ['Object ' num2str(o)];
    end
    
    legend(objectLegend);
    %}

end