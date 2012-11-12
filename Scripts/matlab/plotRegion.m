
%  plotRegion.m
%  SMI
%
%  Created by Bedeho Mender on 15/11/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%

%function [outputPatternsPlot, MeanObjects, MeanTransforms, orthogonalityIndex, regionOrthogonalizationPlot, regionCorrelationPlot,thetaPlot, thetaMatrix, omegaMatrix, dist, omegaBins, invariancePlot, distributionPlot] = plotRegion(filename, info, dotproduct, region, depth)
function plotRegion(filename, info, dotproduct, netDir)
    
    analysisResults = metrics(filename, info);
    
    disp(['Discarded: ' num2str(100*nnz(analysisResults.DiscardStatus_Linear > 0)/numel(analysisResults.DiscardStatus_Linear)) '%']);
    
    % Psi/lambda scatter plot
    psiLambdaPlot = figure();
    plot(analysisResults.RFSize_Linear, analysisResults.headCenteredNess_Linear, 'ob');
    hold on;
    plot(analysisResults.RFSize_Linear_Clean, analysisResults.headCenteredNess_Linear_Clean, 'or', 'LineWidth', 2);
    xlabel('\psi');
    ylabel('\lambda');
    ylim([-0.1 1]);
    saveFigureAndDelete(psiLambdaPlot, 'psilambda');
    
    % lambda/h scatter plot
    lambdahPlot = figure();
    plot(analysisResults.RFLocation_Linear, analysisResults.headCenteredNess_Linear, 'ob');
    hold on;
    plot(analysisResults.RFLocation_Linear_Clean, analysisResults.headCenteredNess_Linear_Clean, 'or', 'LineWidth', 2);
    xlabel('h-value');
    ylabel('\lambda');
    ylim([-0.1 1]);
    xlim([info.targets(end) info.targets(1)]);
    saveFigureAndDelete(lambdahPlot, 'lambdah');
    
    % Psi/h
    psiHPlot = figure();
    plot(analysisResults.RFSize_Linear, analysisResults.RFLocation_Linear, 'ob');
    hold on;
    plot(analysisResults.RFSize_Linear_Clean, analysisResults.RFLocation_Linear_Clean, 'or', 'LineWidth', 2);
    xlabel('\psi');
    ylabel('h-value');
    saveFigureAndDelete(psiHPlot, 'psih');
    
    % h/Psi/Lambda
    hPsiLambdaPlot = figure();
    scatter3(analysisResults.RFLocation_Linear_Clean, analysisResults.RFSize_Linear_Clean, analysisResults.headCenteredNess_Linear_Clean);
    xlabel('h-value');
    ylabel('\psi');
    zlabel('\lambda');
    saveFigureAndDelete(hPsiLambdaPlot, 'hpsilambda');
    
    % Save for collation
    save([netDir '/analysisResults.mat'], 'analysisResults' );
    
    function saveFigureAndDelete(fig, name)
        
        saveas(fig, [netDir '/' name '.eps']);
        saveas(fig, [netDir '/' name '.png']);
        delete(fig);  
    end
    

    %{
    % Lambda
    lambdaPlot = figure();
    plot(sort(headCenteredNess_LIN,'descend'));
    axis([0 numel(headCenteredNess_LIN) -1.1 1.1]);
    xlabel('Cell Rank');
    ylabel('\lambda');
    saveFigureAndDelete(lambdaPlot, 'headCenteredNess');
    
    % Psi
    psiPlot = figure();
    plot(sort(RFSize_LIN,'descend'));
    %axis([0 numel(psi) -1.1 1.1]);
    xlabel('Cell Rank');
    ylabel('\psi');
    saveFigureAndDelete(psiPlot, 'RFSize');
    
    % h-value
    hValuePlot = figure();
    hTOP = RFLocation_LIN;
    hTOP(headCenteredNess_LIN < 0.8) = [];     % shave out bottom
    hist(hTOP,50);
    xlabel('Head-centered Space (deg)');
    ylabel('h-value');
    saveFigureAndDelete(hValuePlot, 'RFLocation_LIN');
    %}


%{
    % Get dimensions
    %[networkDimensions, nrOfPresentLayers, historyDimensions] = getHistoryDimensions(filename);
    
    %numCells = networkDimensions(end).y_dimension * networkDimensions(end).x_dimension;
    
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
    
%}
    %numTargets = length(info.targets);
    %nrOfEyePositionsInTesting = length(info.eyePositions);
    
    % analysis
    % (1) = \lambda^a
    % (2) = \psi^a
    % (3) = \Omega^a
    % (4) = best match target
    % (5...[5+#targets]) = \chi
    

    %{
    % regionOrthogonalizationPlot
    saveas(regionOrthogonalizationPlot, [netDir '/orthogonality.eps']);
    saveas(regionOrthogonalizationPlot, [netDir '/orthogonality.png']);
    delete(regionOrthogonalizationPlot);

    % outputPatternsPlot
    saveas(outputPatternsPlot, [netDir '/outputOrthogonality.eps']);
    saveas(outputPatternsPlot, [netDir '/outputOrthogonality.png']);
    delete(outputPatternsPlot);

    %}

    % outputPatternsPlot
    %saveas(invariancePlot, [netDir '/invariance.eps']);
    %saveas(invariancePlot, [netDir '/invariance.png']);
    %print(invariancePlot, '-depsc2', '-painters', [netDir '/' experiment '_invariance.eps']);
    %delete(invariancePlot);

    % distributionPlot
    %saveas(distributionPlot, [netDir '/dist.eps']);
    %saveas(distributionPlot, [netDir '/dist.png']);
    %delete(distributionPlot);

    % thetaPlot
    %saveas(thetaPlot, [netDir '/theta.eps']);
    %saveas(thetaPlot, [netDir '/theta.png']);
    %delete(thetaPlot);

    % Save results for summary

    %summary(counter).nrOfHeadCenteredCells = nnz(singleCell > 0); % Count number of cells with positive correlation
    %summary(counter).orthogonalityIndex = orthogonalityIndex;
    %summary(counter).MeanObjects = MeanObjects;
    %summary(counter).MeanTransforms = MeanTransforms;

    %summary(counter).fullInvariance = fullInvariance;
    %summary(counter).meanInvariance = meanInvariance;
    %summary(counter).multiCell = multiCell;
    %summary(counter).nrOfSingleCell = nrOfSingleCell;
    
    % Plot Omega/preference
    %figure();
    %subplot(1,2,1);
    %imagesc(omegaMatrix);
    %subplot(1,2,2);
    %imagesc(preferenceMatrix);
    %title('region');
    
    % Head distribution
    %[distributionPlot, dist, omegaBins] = doDistributionPlot(omegaMatrix,preferenceMatrix);
    
    % IMAGESC CORRELATION
    %correlationVector = corr{region-1}(:);
    %sortedCorrelations = sort(correlationVector,'descend');
    %plot(sortedCorrelations,'-ob');
    %axis([0 length(correlationVector) -1.1 1.1]);
    
    %% Theta plot
    %thetaPlot = figure();
    %theta = thetaMatrix(:);
    %plot(sort(theta,'descend'));
    %title('Retinal Confusion');
    %ylim([0 0.005]);
    %axis([0 numel(theta) -1.1 1.1]);
    %xlabel('Cell Rank');
    %ylabel('\Omega_a');
    
    
    %% ORTHOGONALITY
    %{
    
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
    %}
    
    %{
    outputPatternsPlot = 0;
    regionOrthogonalizationPlot = 0;
    outputPatterns = 0;
    orthogonalityIndex = 0;
    inputCorrelations = 0;
    outputCorrelations = 0;
    %}
    
    %{
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
    %}

    %{
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
    %}
    
    % OLD CORRELATION
    
    %{
    % Compute region correlation
    corr = regionCorrelation(filename, info.nrOfEyePositionsInTesting);
    
    % Plot region correlation
    regionCorrelationPlot = figure();
    
    % IMAGESC CORRELATION
    imagesc(corr{region-1});
    colorbar;
    %}
end