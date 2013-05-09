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

%  scatterPlotWithMarginalHistograms({randn(200,1), randn(400,1)*0.3}, {randn(200,1)+1, randn(400,1)*1.6},'XTitle','Receptive Field Location (deg)','YTitle','Head-Centerednes','Legends',{'Untrained','Trained'},'XLim',[-5 2],'YLim',[-5 7])

function [maxPlot, yProjectionAxis, scatterAxis, xProjectionAxis, XLim, YLim] = scatterPlotWithMarginalHistograms(X, Y, varargin)

    % Process varargs
    args = vararginProcessing(varargin, {'XTitle', 'YTitle', 'XLim', 'YLim', 'Legends', 'FaceColors', 'EdgeColors', 'NumberOfBins', 'MarkerSize', 'Location', 'YLabelOffset', 'LabelFontSize', 'AxisFontSize'}); % 'XPercentiles', 'YPercentiles',
    
    % Get dimensions
    if(length(X) ~= length(Y))
        error('Unqeual number of X and Y datasets');
    end
    
    nrOfDataSets = length(X);
        
    % Figure Dimensions
    scatterDim = 200;
    titleEdgeMargin = 50;
    scatterToProjectionMargin = 10;
    projectionHeight = 40;
    totalFigureHeight = scatterDim+titleEdgeMargin+scatterToProjectionMargin+projectionHeight;
    totalFigureWidth = totalFigureHeight;
    projectionOffset = titleEdgeMargin+scatterDim+scatterToProjectionMargin; % Offset between left (or bottom) of scatter plot and figure left (or bottom)
    

    % Process arguments
    % Colors
    % Light = {[0.4,0.4,0.9]; [0.9,0.4,0.4]}; % , [0.4,0.4,0.4]
    % Dark  = {[0.3,0.3,0.8]; [0.8,0.3,0.3]}; % , [0.3,0.3,0.3] 
    
    FaceColors      = processOptionalArgument('FaceColors', {[1,0,0]; [0,0,1]}); % {[0.3,0.3,0.8]; [0.8,0.3,0.3]}
    EdgeColors      = processOptionalArgument('EdgeColors', FaceColors);
    NumberOfBins    = processOptionalArgument('NumberOfBins', 40);
    MarkerSize      = processOptionalArgument('MarkerSize', 3);
    Location        = processOptionalArgument('Location', 'NorthEast'); % SouthWest
    %YLabelOffset    = processOptionalArgument('YLabelOffset', 5);
    LabelFontSize   = processOptionalArgument('LabelFontSize', 15);
    AxisFontSize    = processOptionalArgument('AxisFontSize', 14);
    LegendFontSize    = processOptionalArgument('LegendFontSize', 10);
    
    %% Main plot

    % Create figure
    maxPlot = figure('Units','Pixels','position', [1000 1000 totalFigureWidth totalFigureHeight]);

    yProjectionAxis = subplot(2,2,1);
    scatterAxis = subplot(2,2,2);
    xProjectionAxis = subplot(2,2,4);
    
    % Allocate space for histograms
    
    XHistograms = zeros(NumberOfBins, nrOfDataSets);
    YHistograms = zeros(NumberOfBins, nrOfDataSets);
    
    %% Limits
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
    
    xDivide = linspace(minX, maxX, NumberOfBins+1);
    yDivide = linspace(minY, maxY, NumberOfBins+1);
    
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
        hx = histc(xData, xDivide);
        hy = histc(yData, yDivide);
        
        XHistograms(:,i) =  hx(1:(end-1))./ sizeOfDataSet;
        YHistograms(:,i) =  hy(1:(end-1))./ sizeOfDataSet;
        
        % Add scatter plots
        axes(scatterAxis);
        plot(xData, yData, 'o','MarkerFaceColor', FaceColors{i}, 'MarkerEdgeColor', EdgeColors{i}, 'MarkerSize', MarkerSize);
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
    
    %% Style
    
    % Add legend
    if nrOfDataSets > 1 && isKey(args,'Legends'),
        
        Legends = args('Legends');
        
        if(nrOfDataSets == length(Legends))
            hlegend = legend(Legends,'Location', Location);
            set(hlegend, 'FontSize', LegendFontSize);
        else
            error('Number of data sets does not match number of legends');
        end 
    end
    
    % Set axis font size
    set(gca, 'FontSize', AxisFontSize);
    
    % Add Grid
    grid
    
    % Add Limits
    xlim(XLim);
    ylim(YLim);
    
    %% Add titles
    
    if isKey(args,'XTitle'),
        
        hLabeL = xlabel(args('XTitle'));
        set(hLabeL, 'FontSize', LabelFontSize);
    end
    
    if isKey(args,'YTitle'),
        
        axes(scatterAxis);
        hLabeL = ylabel(args('YTitle'));
        set(hLabeL, 'FontSize', LabelFontSize);
    end
    
    %% Add Projections
    
    % x
    axes(xProjectionAxis);
    hBar = bar(XHistograms,1.0,'stacked','LineStyle','none'); 
    %set(hBar,{'FaceColor'}, FaceColors); %, {'EdgeColor'}, edgeColors
    for i=1:length(hBar),
        set(hBar(i),'FaceColor', FaceColors{i}); %, {'EdgeColor'}, edgeColors
    end
    
    
    % y
    axes(yProjectionAxis);
    hBar = bar(YHistograms,1.0,'stacked','LineStyle','none'); 
    view(-90,90);
    %set(hBar,{'FaceColor'}, FaceColors); %, {'EdgeColor'}, edgeColors
    for i=1:length(hBar),
        set(hBar(i),'FaceColor', FaceColors{i}); %, {'EdgeColor'}, edgeColors
    end
    
    %% Positioning
    % remember, pos = [left, bottom, width, height]
    

    % scatter
    axes(scatterAxis);
    box on;
    set(scatterAxis, 'Units','Pixels', 'pos', [titleEdgeMargin titleEdgeMargin scatterDim scatterDim]);
    
    % y projection
    axes(yProjectionAxis);
    box off
    axis tight
    axis off
    set(gca,'YDir','reverse');
    set(gca,'XAxisLocation','top');
    set(gca,'xtick',[])
    set(gca,'ytick',[]);
    set(yProjectionAxis, 'Units','Pixels', 'pos', [projectionOffset titleEdgeMargin projectionHeight scatterDim]);

    % x projection
    axes(xProjectionAxis);
    set(xProjectionAxis, 'Units','Pixels', 'pos', [titleEdgeMargin projectionOffset scatterDim projectionHeight]);
    
    box off
    axis tight
    axis off
    set(gca,'xtick',[]);
    set(gca,'ytick',[]);
    
    
    
    %{
    outerMargin = 20;
    projectionHeight = 42;
    projectionScatterMargin = 40;
    totalFigureHeight = 2*outerMargin + scatterDim + projectionHeight + projectionScatterMargin;
    totalFigureWidth = totalFigureHeight;
    scatterOffset = (outerMargin+projectionHeight+projectionScatterMargin); % Offset between left (or bottom) of scatter plot and figure left (or bottom)
    
    % scatter
    axes(scatterAxis);
    box on;
    set(scatterAxis, 'Units','Pixels', 'pos', [scatterOffset scatterOffset scatterDim scatterDim]);
    
    % y projection
    axes(yProjectionAxis);
    box off
    axis tight
    axis off
    set(gca,'xtick',[])
    set(gca,'ytick',[]);
    set(yProjectionAxis, 'Units','Pixels', 'pos', [outerMargin scatterOffset projectionHeight scatterDim]);

    % x projection
    axes(xProjectionAxis);
    set(xProjectionAxis, 'Units','Pixels', 'pos', [scatterOffset outerMargin scatterDim projectionHeight]);
    
    box off
    axis tight
    axis off
    set(gca,'YDir','reverse');
    set(gca,'XAxisLocation','top');
    set(gca,'xtick',[]);
    set(gca,'ytick',[]);
    
%}
    
    %% Process an optional argument
    function r = processOptionalArgument(key, default)
        
        if(isKey(args, key)),
            r = args(key);
        else
            r = default;
        end
        
    end
        
    
end