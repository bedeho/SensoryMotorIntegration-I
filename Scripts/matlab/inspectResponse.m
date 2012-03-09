%
%  inspectResponse.m
%  SMI
%
%  Created by Bedeho Mender on 29/04/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%

function inspectResponse(filename, nrOfEyePositionsInTesting)

    % Get dimensions
    [networkDimensions, historyDimensions] = getHistoryDimensions(filename);
    
    % Load data
    [data, objectsPrEyePosition] = regionDataPrEyePosition(filename, nrOfEyePositionsInTesting); % (object, eye_position, row, col, region)
    regionCorrs = regionCorrelation(filename, nrOfEyePositionsInTesting);
    
    % Setup vars
    PLOT_COLS = 4;
    numRegions = length(networkDimensions);
    axisVals = zeros(numRegions, PLOT_COLS); % Save axis that we can lookup 'CurrentPoint' property on callback
    markerSpecifiers = {'r+', 'kv', 'bx', 'cs', 'md', 'y^', 'g.', 'w>'}; %, '<', 'p', 'h'''
    
    objectLegend = cell(nrOfEyePositionsInTesting,1);
    for o=1:nrOfEyePositionsInTesting,
        objectLegend{o} = ['Object ' num2str(o)];
    end
    
    % Get name of this network
    [pathstr, name, ext] = fileparts(filename);
    [pathstr2, netname, ext] = fileparts(pathstr);
    
    network_1 = [pathstr '/' netname '.txt'];
    
    % Get name of related blank network
    network_2 = [pathstr2 '/BlankNetwork/BlankNetwork.txt'];
    
    % Iterate regions to do correlation plot and setup callbacks
    fig = figure('name',filename,'NumberTitle','off');
    for r=2:numRegions
        
        %% Delta plot
        axisVals(r-1,1) = subplot(numRegions, PLOT_COLS, PLOT_COLS*(r-2) + 1); % Save axis
        deltaMatrix = rand(10,10);% painstakingly slow regionDelta(network_1, network_2, r);
        im = imagesc(deltaMatrix);
        daspect([size(deltaMatrix) 1]);
        title('This vs. BlankNetwork weight matrix correlation per cell');
        colorbar;
        set(im, 'ButtonDownFcn', {@responseCallBack, r,1}); % Setup callback
        
        %% Activity indicator
        axisVals(r-1,2) = subplot(numRegions, PLOT_COLS, PLOT_COLS*(r-2) + 2); % Save axis
        
        % TRADITIONAL
        %{ 
        im = imagesc(regionCorrs{r-1});
        title('Head centerede correlation');
        %}
        
        % SIMON
        %%{
        v0 = data{r-1};
        v0(v0 > 0) = 1;  % count all nonzero as 1, error terms have already been removed
        v1 = squeeze(sum(sum(v0))); % sum away
        v2 = v1(:,:,1);
        im = imagesc(v2);         % only do first region
        daspect([size(v2) 1]);
        title('Number of testing locations responded to');
        colorbar;
        %%}
    
        %% ResponseCount historgram
        axisVals(r-1,3) = subplot(numRegions, PLOT_COLS, PLOT_COLS*(r-2) + 3); % Simon model
        noZeros = v2(:);
        noZeros(noZeros == 0) = [];
        hist(noZeros,1:(max(max(v2))));
        title(['Mean: ' num2str(mean2(v2))]);
        set(im, 'ButtonDownFcn', {@responseCallBack, r,2}); % Setup callback
        
        %% Invariance heuristic
        axisVals(r-1,PLOT_COLS) = subplot(numRegions, PLOT_COLS, PLOT_COLS*(r-2) + PLOT_COLS);
        
        responseCounts = invarianceHeuristics(filename, nrOfEyePositionsInTesting);
           
        % Plot a line for each object
        for e=1:nrOfEyePositionsInTesting,

            plot(responseCounts{e}, ['-' markerSpecifiers{e}], 'Linewidth', PLOT_COLS);
            hold all
        end
        
        axis tight
        legend(objectLegend);
        
        hold off
       
    end
    
    % makeFigureFullScreen(fig);
    
    % Callback
    function responseCallBack(varargin)
        
        % Extract region,row,col
        region = varargin{3};
        plotNum = varargin{4};

        pos = get(axisVals(region-1,plotNum), 'CurrentPoint');
        [row, col] = imagescClick(pos(1, 2), pos(1, 1), networkDimensions(region).y_dimension, networkDimensions(region).x_dimension);

        % single left  click => 'SelectionType' = 'normal'
        % single right click => 'SelectionType' = 'alt'
        % double right click => 'SelectionType' = 'open'
        clickType = get(gcf,'SelectionType')
        
        if ~strcmp(clickType,'alt'),
            % Dump correlation
            disp(['Correlation: ' num2str(regionCorrs{region-1}(row,col))]);

            % Setup blank plot
            axisVals(numRegions, [1 PLOT_COLS]) = subplot(numRegions, PLOT_COLS, [PLOT_COLS*(numRegions - 1) + 1 PLOT_COLS*(numRegions - 1) + PLOT_COLS]);

            %axisVals(numRegions, [1 2]) = subplot(numRegions, 2, [2*(numRegions - 1) + 1 2*(numRegions - 1) + 2]);

            %% SIMON STYLE - object based line plot
            %%{

            cla
            
            m = 1.1;

            for h = 1:nrOfEyePositionsInTesting,

                v = squeeze(data{region-1}(:, h, row, col));

                if max(v) > m,
                    m = max(v);
                end

                plot(v, [':' markerSpecifiers{h}]);

                hold all;
            end  

            axis([1 objectsPrEyePosition -0.1 m]);
            legend(objectLegend);
        else
            %Right click
            [path, name, ext] = fileparts(filename);
            [path, name, ext] = fileparts(path);
            
            
            trainingFolder = [path '/Training'];
            
            plotSynapseHistory(trainingFolder, 2, 1, row, col);
        end
        
        %%}
        
        %% OLD STYLE - Bar plot
        %cla
        
        %Simon Style
        %plot(data{region-1}(:, :, row, col));
        %set(gca,'XLim',[0 nrOfEyePositionsInTesting]);
        %set(gca,'YLim',[-0.1 1.1]);
        
        % Old Style
        %bar(data{region-1}(:, :, row, col));
        %set(gca,'XLim',[0 (objectsPrEyePosition+1)])
        
        %set(gca,'XTick', 1:objectsPrEyePosition)
        title(['Row:' num2str(row) ', Col:' num2str(col)]); % ', R:' num2str(region)
    end
end