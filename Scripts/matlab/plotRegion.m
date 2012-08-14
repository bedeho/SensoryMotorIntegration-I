
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
    
    nrOfEyePositionsInTesting = length(info.eyePositions)
    
    %% OLD CORRELATION
    
    %{
    % Compute region correlation
    corr = regionCorrelation(filename, info.nrOfEyePositionsInTesting);
    
    % Plot region correlation
    regionCorrelationPlot = figure();
    
    % IMAGESC CORRELATION
    imagesc(corr{region-1});
    colorbar;
    %}
    
    %% NEW ANALYSIS
    
    % analysis
    % (1) = \lambda^a
    % (2) = \psi^a
    % (3) = \Omega^a
    % (4...[4+#targets]) = \chi
    [analysis] = metrics(filename, info);
    
    regionOmega = analysis(3,:,:);
    corr = sort(regionOmega(:),'descend');
    
    % Plot region correlation
    regionCorrelationPlot = figure();
    
    % IMAGESC CORRELATION
    plot(corr);
    axis([0 numel(corr) -1.1 1.1]);
    xlabel('Cell Rank');
    ylabel('\Omega_a');
    
    %correlationVector = corr{region-1}(:);
    %sortedCorrelations = sort(correlationVector,'descend');
    %plot(sortedCorrelations,'-ob');
    %axis([0 length(correlationVector) -1.1 1.1]);
    
    %% ORTHOGONALITY
    
    % Multiple indexes
    regionOrthogonalizationPlot = figure();
    
    % Compute orthogonalization
    [outputPatterns, orthogonalityIndex, inputCorrelations, outputCorrelations] = regionOrthogonality(filename, nrOfEyePositionsInTesting, dotproduct, region);
        
    scatter(inputCorrelations,outputCorrelations);
    xlabel('Input Correlations');
    ylabel('Output Correlations');
    
    axis([-0.1 1.1 -0.1 1.1]);
    line([0,1],[0,1], 'linewidth',1,'color',[1,0,0]);
    
    % Plot
    outputPatternsPlot = figure();
    imagesc(outputPatterns);
    colorbar;
    
    %% Invariance & Selectivity
    [MeanObjects, MeanTransforms] = regionTrace(filename, nrOfEyePositionsInTesting);
    
    %% Compute invariance heuristic
    invariancePlot = figure();
    
    responseCounts = invarianceHeuristics(filename, nrOfEyePositionsInTesting);

    bar(responseCounts');
    
    %{

    responseCounts = invarianceHeuristics(filename, nrOfEyePositionsInTesting);
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