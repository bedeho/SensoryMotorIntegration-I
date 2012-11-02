%
%  scatterPlotWithMarginalHistograms.m
%  SMI (VisBack copy)
%
%  Created by Bedeho Mender on 12/10/12.
%  Copyright 2012 OFTNAI. All rights reserved.

function handle = scatterPlotWithMarginalHistograms(X, Y, XLabel, YLabel, Legends)

    % Marks
    %markerSpecifiers = {'+', 'v', 'x', 's', 'd', '^', '.', '>', '+', 'v', 'x', 's', 'd', '^', '.', '>','+', 'v', 'x', 's', 'd', '^', '.', '>'};
    colors = {'r', 'b','k','c', 'm', 'y', 'g', 'w'};

    % Create figure
    handle = figure();
    
    % Get dimensions
    [nrOfDatasets sizeOfDataset] = size(X);
    
    % Get normalizing values
    %maxX = max(max(X'));
    %maxY = max(max(Y'));
    
    %ha = tight_subplot(2,2);
    
    %subaxis(2, 2, 2, 'Spacing', 0);
    
    %spacing = 0.0;
    %padding = 0.0;
    %margin = 0;
    
    %x = 0;
    %ML = 0;
    %v = [, 'Padding', padding, 'Margin', margin];
    
    ADD COLOR to transparant plot, and make line more solid
    
    %{
    figure
hist(data1,20)
h = findobj(gca,?Type?,'patch?);
set(h,?FaceColor?,'r?,'EdgeColor?,'w?,'facealpha?,0.75)
hold on
hist(data2,20)
h = findobj(gca,?Type?,'patch?);
set(h,?facealpha?,0.75);
ylabel(?counts?)
xlabel(?gene-tree-length/species-tree-length?)
legend(?no HGT?,'HGT?)
title(?p = 0.5?);
    %}
    
    for i=1:nrOfDatasets,
        
        % Add scatter plots
        subplot(2,2,2);
        %subaxis(2, 2, 2, 'Spacing', x);
        %axes(ha(2));
        hold on;
        plot(X(i,:), Y(i,:), ['o' colors{i}]);
        
        % Add y projections
        subplot(2,2,1);
        %subaxis(2, 2, 1, 'Spacing', x);
        %axes(ha(1));
        yProjections = hist(Y(i,:),30);
        hold on;
        plot(yProjections, colors{i});
        
        % Add x projections
        subplot(2,2,4);
        %subaxis(2, 2, 4, 'Spacing', x);
        %axes(ha(4));
        xProjections = hist(X(i,:),30);
        hold on;
        plot(xProjections, colors{i});
    end

    h = subplot(2,2,1);
    box off
    axis tight
    %axis off
    camroll(90)
    pbaspect([1.0 0.25 1.0]);
    set(gca,'xtick',[])
    set(gca,'ytick',[]);
    p = get(h, 'pos');
    p(1) = p(1) - 0.20;
    set(h, 'pos', p);
    
    
    h = subplot(2,2,2);
    box on;
    p = get(h, 'pos');
    p = [p(1) - 0.36, p(2)-0.1, 0.7, 0.7];
    set(h, 'pos', p);
    xlabel(XLabel);
    ylabel(YLabel);
    
    
    h = subplot(2,2,4);
    p = get(h, 'pos');
    p(1) = p(1) - 0.36;
    p(2) = p(2) + 0.15;
    set(h, 'pos', p);
    box off
    axis tight
    %axis off
    set(gca,'YDir','reverse');
    set(gca,'XAxisLocation','top');
    set(gca,'xtick',[]);
    set(gca,'ytick',[]);
    pbaspect([1.0 0.2 1.0])

    
    % Add legends: , Legends{nrOfDatasets}
   
end