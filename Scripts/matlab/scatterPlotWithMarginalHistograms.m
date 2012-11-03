%
%  scatterPlotWithMarginalHistograms.m
%  SMI (VisBack copy)
%
%  Created by Bedeho Mender on 12/10/12.
%  Copyright 2012 OFTNAI. All rights reserved.
%
%  X = (point,dataset) for x components
%  Y = (point,dataset) for y components

function [maxPlot, miniPlot yProjectionAxis, scatterAxis, xProjectionAxis] = scatterPlotWithMarginalHistograms(X, Y, XLabel, YLabel, Legends)

    % Get dimensions
    [sizeOfDataset nrOfDatasets] = size(X);

    % Check arguments 
    if(any([sizeOfDataset nrOfDatasets] ~= size(Y)))
        error('X,Y data incompatible');
    elseif(nrOfDatasets ~= length(Legends))
        error('Number of data sets does not match number of legends');
    end

    %% Parameters
    
    % Dimensions
    scatterDim = 200;
    outerMargin = 20;
    projectionHeight = 42;
    projectionScatterMargin = 40;
    totalFigureHeight = 2*outerMargin + scatterDim + projectionHeight + projectionScatterMargin;
    totalFigureWidth = totalFigureHeight;
    
    % Colors,
    % untrained = blue, 
    % trained = red,
    % discarded = grey
    % percentile line
    
    color = {[0.4,0.4,0.9]; [0.9,0.4,0.4]}; % , [0.4,0.4,0.4]
    colorDarker = {[0.3,0.3,0.8]; [0.8,0.3,0.3]};
    
    %% Main plot

    % Create figure
    maxPlot = figure('Units','Pixels','position', [800 800 totalFigureWidth totalFigureHeight]);

    yProjectionAxis = subplot(2,2,1);
    scatterAxis = subplot(2,2,2);
    xProjectionAxis = subplot(2,2,4);
    
    % Do scatters
    for i=1:nrOfDatasets,
        
        % Add scatter plots
        axes(scatterAxis);
        plot(X(:,i), Y(:,i), 'o','MarkerFaceColor', color{i}, 'MarkerEdgeColor', color{i}, 'MarkerEdgeColor', colorDarker{i}, 'MarkerSize', 4);
        hold on;
        
    end
    
    % Add legend
    legend(Legends)
    
    % Add Grid
    grid
    
    % Make histograms
    NumberOfBins = 30;
    XHistograms = hist(X, NumberOfBins);
    YHistograms = hist(Y, NumberOfBins);
    
    % Normalize datasets (independently)
    XHistograms = XHistograms ./ sizeOfDataset;
    YHistograms = YHistograms ./ sizeOfDataset;
    
    % x
    axes(xProjectionAxis);
    hBar = bar(XHistograms,1.0,'stacked');
    set(hBar,{'FaceColor'}, color);
    
    % y
    axes(yProjectionAxis);
    hBar = bar(YHistograms,1.0,'stacked');
    view(270,270);%camroll(90);
    set(hBar,{'FaceColor'}, color);
    

    %%
    % Do positioning: 
    % remimber, pos = [left, bottom, width, height]
    scatterOffset = (outerMargin+projectionHeight+projectionScatterMargin); % Offset between left (or bottom) of scatter plot and figure left (or bottom)
    
    % scatter
    axes(scatterAxis);
    box on;
    p = [scatterOffset scatterOffset scatterDim scatterDim];
    set(scatterAxis, 'Units','Pixels', 'pos', p);
    xlabel(XLabel);
    ylabel(YLabel);

    % y-projection
    axes(yProjectionAxis);
    box off
    axis tight
    axis off
    
    set(gca,'xtick',[])
    set(gca,'ytick',[]);
    p = [outerMargin scatterOffset projectionHeight scatterDim];
    set(yProjectionAxis, 'Units','Pixels', 'pos', p);
    %ylim([0 0.25]);

    % x-projection
    axes(xProjectionAxis);
    p = [scatterOffset outerMargin scatterDim projectionHeight];
    set(xProjectionAxis, 'Units','Pixels', 'pos', p);
    box off
    axis tight
    axis off
    set(gca,'YDir','reverse');
    set(gca,'XAxisLocation','top');
    set(gca,'xtick',[]);
    set(gca,'ytick',[]);
    %ylim([0 max(max(YHistograms))]);
    
    %% Mini plot
    miniPlot = figure;
    
    for i=1:nrOfDatasets,
        
        plot(X(:,i), Y(:,i),'o','MarkerFaceColor', color{i}, 'MarkerEdgeColor', color{i}, 'MarkerSize', 4);
        hold on;
        
    end
    
    set(gca,'xtick',[]);
    set(gca,'ytick',[]);
    
end