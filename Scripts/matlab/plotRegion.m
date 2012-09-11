
%  plotRegion.m
%  SMI
%
%  Created by Bedeho Mender on 15/11/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%

function [outputPatternsPlot, MeanObjects, MeanTransforms, orthogonalityIndex, regionOrthogonalizationPlot, regionCorrelationPlot, omegaMatrix, dist, omegaBins, invariancePlot, distributionPlot] = plotRegion(filename, info, dotproduct, region, depth)

    % Get dimensions
    [networkDimensions, nrOfPresentLayers, historyDimensions] = getHistoryDimensions(filename);
    
    numCells = networkDimensions(end).y_dimension * networkDimensions(end).x_dimension;
    
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
    
    numTargets = length(info.targets);
    nrOfEyePositionsInTesting = length(info.eyePositions);
    
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
    % (4) = best match target
    % (5...[5+#targets]) = \chi
    [analysis] = metrics(filename, info);
    
    omegaMatrix = squeeze(analysis(3,:,:));
    preferenceMatrix = squeeze(analysis(4,:,:));
    corr = sort(omegaMatrix(:),'descend');
    
    % Plot region correlation
    regionCorrelationPlot = figure();
    
    plot(corr);
    axis([0 numel(corr) -1.1 1.1]);
    xlabel('Cell Rank');
    ylabel('\Omega_a');
    
    % Plot Omega/preference
    %figure();
    %subplot(1,2,1);
    %imagesc(omegaMatrix);
    %subplot(1,2,2);
    %imagesc(preferenceMatrix);
    %title('region');
    
    % Head distribution
    [distributionPlot, dist, omegaBins] = doDistributionPlot(omegaMatrix,preferenceMatrix);
    
    % IMAGESC CORRELATION
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

    bar(responseCounts);
    
    legends = cell(1,numTargets);
    for h=1:numTargets,
        legends{h} = ['Head-centered Location ' num2str(info.targets(h)) '^{\circ}'];
    end
    
    hLegend = legend(legends);
    legend('boxoff')
    hTitle = title('')%; title('Exclusive Cells');
    hXLabel = xlabel('#Effective Fixation Locations');
    hYLabel = ylabel('Frequency');

    set( gca                       , ...
        'FontName'   , 'Helvetica' );
    set([hTitle, hXLabel, hYLabel], ...
        'FontName'   , 'AvantGarde');
    set([hLegend, gca]             , ...
        'FontSize'   , 14           );
    set([hXLabel, hYLabel]  , ...
        'FontSize'   , 18          );
    set( hTitle                    , ...
        'FontSize'   , 24          , ...
        'FontWeight' , 'bold'      );
    
    set(hLegend        , ...
      'LineWidth'       , 2  );

    set(gca, ...
      'Box'         , 'on'     , ...
      'TickDir'     , 'in'     , ...
      'TickLength'  , [.02 .02] , ...
      'XMinorTick'  , 'off'      , ...
      'YMinorTick'  , 'off'      , ...
      'YGrid'       , 'off'      , ...
      'LineWidth'   , 2         );
    
    ylim([0 0.13*numCells]); % We dont normalize with peak, but rather with fixed number so visual comparison is easy
    
    
    %%
    
    function [p,dist,omegaBins] = doDistributionPlot(omegaMatrix,preferenceMatrix)
        
        % Make figure
        p = figure();
        
        % Omega resoltion
        dO = 0.2;
        omegaBins = dO:dO:1; % Bin b (b=1,2,...) keeps all cells with omega value in range dO * (b-1,b];
        
        % make space
        % dist(1, bin) = min
        % dist(2, bin) = mean
        % dist(3, bin) = max
        dist = zeros(3 + numTargets,length(omegaBins));
        
        % targetBins
        targetBins = (0:numTargets) + 0.5;
        
        % Populate bins
        for b = 1:length(omegaBins),
        
          % Find eligable neurons: omega value within bin AND with a good
          % target match (match > 0)
          neurons = squeeze(omegaMatrix > (b-1)*dO & omegaMatrix <= b*dO & preferenceMatrix > 0); %
          
          % Make histogram of neurons over targets they prefer
          histogram = histc(analysis(4,neurons),targetBins);
          cHist = histogram(1:(end-1));
          
          % Save result
          dist(1,b) = min(cHist);
          dist(2,b) = mean(cHist);
          dist(3,b) = max(cHist);
          dist(4:end,b) = cHist;
        
        end
        
        % Plot bar
        upper = dist(3,:) - dist(2,:);
        lower = dist(2,:) - dist(1,:);
        X = 1:length(omegaBins);
        Y = dist(2,:);
        errorbar(X,Y,lower,upper)
        %plot(1:length(dist),dist(2,:));
        
    end
end


    
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