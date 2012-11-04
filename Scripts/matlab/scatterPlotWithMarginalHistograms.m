%
%  scatterPlotWithMarginalHistograms.m
%  SMI (VisBack copy)
%
%  Created by Bedeho Mender on 12/10/12.
%  Copyright 2012 OFTNAI. All rights reserved.
%
%  X = (point,dataset) for x components
%  Y = (point,dataset) for y components

function [maxPlot, miniPlot yProjectionAxis, scatterAxis, xProjectionAxis] = scatterPlotWithMarginalHistograms(X, Y, XLabel, YLabel, Legends, YLim, XLim)

    % Get dimensions
    if(length(X) ~= length(Y))
        error('Unqeual number of X and Y datasets');
    elseif(length(X) ~= length(Legends))
        error('Number of data sets does not match number of legends');
    end
    
    nrOfDataSets = length(X);

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
    
    % Allocate space for histograms
    NumberOfBins = 30;
    XHistograms = zeros(NumberOfBins, nrOfDataSets);
    YHistograms = zeros(NumberOfBins, nrOfDataSets);
    
    % Do scatters
    for i=1:nrOfDataSets,
        
        % Get data
        xData = X{i};
        yData = Y{i};
        
        if length(xData) ~= length(yData),
            error(['X and Y component of of dataset ' num2str(i) ' do not match.');
        else 
            sizeOfDataSet = length(xData);
        end
        
        % Make normalize histograms
        XHistograms(:,i) = hist(xData, NumberOfBins) ./ sizeOfDataSet;
        YHistograms(:,i) = hist(yData, NumberOfBins) ./ sizeOfDataSet;
        
        % Add scatter plots
        axes(scatterAxis);
        plot(xData, yData, 'o','MarkerFaceColor', color{i}, 'MarkerEdgeColor', color{i}, 'MarkerEdgeColor', colorDarker{i}, 'MarkerSize', 4);
        hold on;
        
        % Add x percentile lines
        if X
        xPercentile = prctile(xData,p)
        
    end
    
    % Add legend
    if nrOfDataSets > 1,
        legend(Legends,'Location','SouthEast')
    end
    
    % Add Grid
    grid
    
    % Add x projection
    axes(xProjectionAxis);
    hBar = bar(XHistograms,1.0,'stacked','LineStyle','none'); 
    set(hBar,{'FaceColor'}, color); %, {'EdgeColor'}, colorDarker
    
    % Add y projection
    axes(yProjectionAxis);
    hBar = bar(YHistograms,1.0,'stacked','LineStyle','none'); 
    view(270,270);%camroll(90);
    set(hBar,{'FaceColor'}, color); %, {'EdgeColor'}, colorDarker
    
    % Positioning: 
    % remember, pos = [left, bottom, width, height]
    scatterOffset = (outerMargin+projectionHeight+projectionScatterMargin); % Offset between left (or bottom) of scatter plot and figure left (or bottom)
    
    % scatter
    axes(scatterAxis);
    box on;
    p = [scatterOffset scatterOffset scatterDim scatterDim];
    set(scatterAxis, 'Units','Pixels', 'pos', p);
    xlabel(XLabel);
    ylabel(YLabel);
    
    if nargin > 5,
        ylim(YLim);
        if nargin > 6,
            xlim(XLim);
        end
    end

    % y projection
    axes(yProjectionAxis);
    box off
    axis tight
    axis off
    
    set(gca,'xtick',[])
    set(gca,'ytick',[]);
    p = [outerMargin scatterOffset projectionHeight scatterDim];
    set(yProjectionAxis, 'Units','Pixels', 'pos', p);

    % x projection
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
    
    %% Mini plot
    miniPlot = figure;
    
    for i=1:nrOfDatasets,
        
        plot(X(:,i), Y(:,i),'o','MarkerFaceColor', color{i}, 'MarkerEdgeColor', color{i}, 'MarkerSize', 4);
        hold on;
        
    end
    
    set(gca,'xtick',[]);
    set(gca,'ytick',[]);
    
end