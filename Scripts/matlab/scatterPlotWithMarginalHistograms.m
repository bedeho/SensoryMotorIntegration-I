%
%  scatterPlotWithMarginalHistograms.m
%  SMI (VisBack copy)
%
%  Created by Bedeho Mender on 12/10/12.
%  Copyright 2012 OFTNAI. All rights reserved.
%
%  X = (point,dataset) for x components
%  Y = (point,dataset) for y components
%  varargin = variable argument list for controlling appearance

% scatterPlotWithMarginalHistograms({randn(200,1), randn(400,1)*0.3}, {randn(200,1)+1, randn(400,1)*1.6},'XTitle','Receptive Field Location (deg)','YTitle','Head-Centerednes','Legends',{'Untrained','Trained'})

function [maxPlot, miniPlot yProjectionAxis, scatterAxis, xProjectionAxis] = scatterPlotWithMarginalHistograms(X, Y, varargin)

    % Process varargs
    args = vararginProcessing(varargin, {'XTitle', 'YTitle', 'XLim', 'YLim', 'Legends', 'FaceColors', 'EdgeColors'}); % 'XPercentiles', 'YPercentiles',
    
    % Get dimensions
    if(length(X) ~= length(Y))
        error('Unqeual number of X and Y datasets');
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
    
    if(isKey(args, 'FaceColors')),
        faceColors = args('FaceColors')
    else
        faceColors ={[0.4,0.4,0.9]; [0.9,0.4,0.4]}; % , [0.4,0.4,0.4]
    end
       
    if(isKey(args, 'EdgeColors')),
        edgeColors = args('EdgeColors')
    else
        edgeColors = {[0.3,0.3,0.8]; [0.8,0.3,0.3]}; % , [0.3,0.3,0.3]
    end

    
    %% Main plot

    % Create figure
    maxPlot = figure('Units','Pixels','position', [800 800 totalFigureWidth totalFigureHeight]);

    yProjectionAxis = subplot(2,2,1);
    scatterAxis = subplot(2,2,2);
    xProjectionAxis = subplot(2,2,4);
    
    % Allocate space for histograms
    NumberOfBins = 40;
    XHistograms = zeros(NumberOfBins, nrOfDataSets);
    YHistograms = zeros(NumberOfBins, nrOfDataSets);
    
    if(isKey(args, 'XLim') && isKey(args, 'YLim')),
        
        XLim = args('XLim');
        YLim = args('YLim');
        
        minX = XLim(1);
        maxX = XLim(2);
        minY = YLim(1);
        maxY = YLim(2);

    else
    
        % Find maximum number
        maxX = 0;
        minX = inf;
        maxY = 0;
        minY = inf;
        
        for i=1:nrOfDataSets,

            % Get data
            xData = X{i};
            yData = Y{i};

            % Find limits
            maxX = max(maxX, max(xData));
            minX = min(minX, min(xData));
            maxY = max(maxY, max(yData));
            minY = min(minY, min(yData));

        end
        
        XLim = [minX maxX];
        YLim = [minY maxY];
    end
    
    xDivide = linspace(minX, maxX, NumberOfBins);
    yDivide = linspace(minY, maxY, NumberOfBins);
    
    % Do scatters
    for i=1:nrOfDataSets,
        
        % Get data
        xData = X{i};
        yData = Y{i};
        
        if length(xData) ~= length(yData),
            error(['X and Y component of of dataset ' num2str(i) ' do not match.']);
        else 
            sizeOfDataSet = length(xData);
        end
        
        % Make normalize histograms
        XHistograms(:,i) = histc(xData, xDivide) ./ sizeOfDataSet;
        YHistograms(:,i) = histc(yData, yDivide) ./ sizeOfDataSet;
        
        % Add scatter plots
        axes(scatterAxis);
        plot(xData, yData, 'o','MarkerFaceColor', faceColors{i}, 'MarkerEdgeColor', edgeColors{i}, 'MarkerSize', 4);
        hold on;
        
        %{
        % Add x percentile lines
        if isKey(args, 'XPercentiles'),
            p = args('XPercentiles');
            xPercentile = prctile(xData,p(i));
            xmax = 
            
        end
        %}
        
    end
    
    % Add legend
    if nrOfDataSets > 1 && isKey(args,'Legends'),
        
        Legends = args('Legends');
        
        if(nrOfDataSets == length(Legends))
            legend(Legends, 'Location', 'SouthEast');
        else
            error('Number of data sets does not match number of legends');
        end 
    end
    
    % Add Grid
    grid
    
    % Add x projection
    axes(xProjectionAxis);
    hBar = bar(XHistograms,1.0,'stacked','LineStyle','none'); 
    set(hBar,{'FaceColor'}, faceColors); %, {'EdgeColor'}, edgeColors
    
    % Add y projection
    axes(yProjectionAxis);
    hBar = bar(YHistograms,1.0,'stacked','LineStyle','none'); 
    view(-90,90);
    set(hBar,{'FaceColor'}, faceColors); %, {'EdgeColor'}, edgeColors
    
    % Positioning: 
    % remember, pos = [left, bottom, width, height]
    scatterOffset = (outerMargin+projectionHeight+projectionScatterMargin); % Offset between left (or bottom) of scatter plot and figure left (or bottom)
    
    % scatter
    axes(scatterAxis);
    box on;
    p = [scatterOffset scatterOffset scatterDim scatterDim];
    set(scatterAxis, 'Units','Pixels', 'pos', p);
    
    if isKey(args,'XTitle'),
        xlabel(args('XTitle'));
    end
    
    if isKey(args,'YTitle'),
        ylabel(args('YTitle'));
    end
    
    xlim(XLim);
    ylim(YLim);
    
    %{
    if isKey(args,'XLim'),
        xlim(args('XLim'));
    end
    
    if isKey(args,'YLim'),
        ylim(args('YLim'));
    end
    %}
    
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
    
    for i=1:nrOfDataSets,
        
        plot(X{i}, Y{i},'o','MarkerFaceColor', faceColors{i},'MarkerEdgeColor', faceColors{i}, 'MarkerSize', 4);
        hold on;
        
    end
    
    set(gca,'xtick',[]);
    set(gca,'ytick',[]);
    
end