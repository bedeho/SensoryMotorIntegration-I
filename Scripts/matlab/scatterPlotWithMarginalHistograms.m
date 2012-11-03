%
%  scatterPlotWithMarginalHistograms.m
%  SMI (VisBack copy)
%
%  Created by Bedeho Mender on 12/10/12.
%  Copyright 2012 OFTNAI. All rights reserved.

function handle = scatterPlotWithMarginalHistograms(X, Y, XLabel, YLabel) % , Color, Mark

    % Dimensions
    scatterDim = 200;
    outerMargin = 20;
    
    projectionHeight = 42;
    projectionScatterMargin = 40;
    
    totalFigureHeight = 2*outerMargin + scatterDim + projectionHeight + projectionScatterMargin;
    totalFigureWidth = totalFigureHeight;
    
    % Colors
    mainColor = {[1,0.4,0.6]};
    borderColor = {[0.4,0.4,0.4]};

    % Create figure
    handle = figure('Units','Pixels','position', [800 800 totalFigureWidth totalFigureHeight]);
    
    % Get dimensions
    [nrOfDatasets sizeOfDataset] = size(X);
    
    % Get normalizing values
    %maxX = max(max(X'));
    %maxY = max(max(Y'));
    
    %
    % colors
    % legends
    % max value on each projection
    %ADD COLOR to transparant plot, and make line more solid
    
    yProjectionAxis = subplot(2,2,1);
    scatterAxis = subplot(2,2,2);
    xProjectionAxis = subplot(2,2,4);
    
    for i=1:nrOfDatasets,
        
        % Add scatter plots
        axes(scatterAxis);
        hold on;
        plot(X(i,:), Y(i,:), 'o','Color',mainColor{i});
        
        % Add y projections
        axes(yProjectionAxis);
        hist(Y(i,:),30,'r');
        h = findobj(gca,'Type','patch');
        set(h,'FaceColor', mainColor{i},'EdgeColor', borderColor{i},'facealpha',0.75);
        hold on;
        
        % Add x projections
        axes(xProjectionAxis);
        hist(X(i,:),30);
        h = findobj(gca,'Type','patch');
        set(h,'FaceColor', mainColor{i},'EdgeColor', borderColor{i},'facealpha',0.75);
        hold on;
    end
    
    % Do positioning: remimber, pos = [left, bottom, width, height]
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
    %axis off
    camroll(90)
    set(gca,'xtick',[])
    set(gca,'ytick',[]);
    p = [outerMargin scatterOffset projectionHeight scatterDim];
    set(yProjectionAxis, 'Units','Pixels', 'pos', p);

    % x-projection
    axes(xProjectionAxis);
    p = [scatterOffset outerMargin scatterDim projectionHeight];
    set(xProjectionAxis, 'Units','Pixels', 'pos', p);
    box off
    axis tight
    %axis off
    set(gca,'YDir','reverse');
    set(gca,'XAxisLocation','top');
    set(gca,'xtick',[]);
    set(gca,'ytick',[]);
    
    % Add legends: , Legends{nrOfDatasets}
   
end