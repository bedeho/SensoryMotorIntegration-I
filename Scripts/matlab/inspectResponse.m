%
%  inspectResponse.m
%  SMI
%
%  Created by Bedeho Mender on 29/04/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%

function inspectResponse(filename, networkFile, nrOfEyePositionsInTesting, stimuliName)

    declareGlobalVars();
    
    global base;
    global THESIS_FIGURE_PATH;
    
    % Get dimensions
    [networkDimensions, nrOfPresentLayers, historyDimensions] = getHistoryDimensions(filename);
    
    % Load data
    [networkDimensions, neuronOffsets] = loadWeightFileHeader(networkFile); % Load weight file header
    [data, objectsPrEyePosition] = regionDataPrEyePosition(filename, nrOfEyePositionsInTesting); % (object, eye_position, row, col, region)
    
    %regionCorrs = regionCorrelation(filename, nrOfEyePositionsInTesting);
    
        
    % Load stimuli
    startDir = pwd;
    cd([base 'Stimuli/' stimuliName]);
    C = load('info.mat');
    info = C.info;
    cd(startDir);
    
    % Read out analysis results
    [pathstr, name, ext] = fileparts(filename);
    
    collation = load([pathstr '/analysisResults.mat']);
    
    analysisResults = collation.analysisResults;
    
    % For scatter
    scatterSpace = [analysisResults.RFLocation_Linear , analysisResults.headCenteredNess_Linear ];
    
    % For distribution
    hmatTOP = analysisResults.RFLocation_Linear;
    hmatTOP(analysisResults.headCenteredNess_Linear < 0.8) = [];     % shave out

    
    % Load single unit recordings
  
    % Decouple name
    [pathstr2, name2, ext2] = fileparts(pathstr);
    manualData = [pathstr '/singleUnits.dat'];
    trainingData = [pathstr2 '/Training/singleUnits.dat'];
    thereIsSingleUnitRecording = exist(trainingData,'file');
    
    if thereIsSingleUnitRecording,
        %[singleUnits, historyDimensions, nrOfPresentLayers] = loadSingleUnitRecordings(manualData);
        [singleUnits, historyDimensions, nrOfPresentLayers] = loadSingleUnitRecordings(trainingData);    
    end
    
    % Setup vars
    doHeadCentered = 1;
    PLOT_COLS = 4;
    numRegions = length(networkDimensions);
    axisVals = zeros(numRegions, PLOT_COLS); % Save axis that we can lookup 'CurrentPoint' property on callback
    %markerSpecifiers = {'r+', 'kv', 'bx', 'cs', 'md', 'y^', 'g.', 'w>', 'r+', 'kv', 'bx', 'cs', 'md', 'y^', 'g.', 'w>','r+', 'kv', 'bx', 'cs', 'md', 'y^', 'g.', 'w>'}; %, '<', 'p', 'h'''
    markerSpecifiers = {'+', 'v', 'x', 's', 'd', '^', '.', '>', '+', 'v', 'x', 's', 'd', '^', '.', '>','+', 'v', 'x', 's', 'd', '^', '.', '>'};
    colors = {'r', 'b','k','c', 'm', 'y', 'g', 'w'};
    topLayerRowDim = networkDimensions(numRegions).x_dimension;
    numEyePositions = length(info.eyePositions);
    numTargets = length(info.targets);
       
    objectLegend = cell(numTargets,1);

    for s=1:numTargets,
        objectLegend{s} = [num2str(info.targets(s)) '^{\circ}'];
    end

    
    if doHeadCentered,
        xTickLabels = cell(numTargets,1);
        xTick = zeros(numTargets,1);
        for s=1:numTargets,
            %s = sprintf('45%c', char(176));
            %xTickLabels{s} = [num2str(info.eyePositions(s)) '^{\circ}'];

            xTickLabels{s} = sprintf([num2str(info.targets(s)) '%c'], char(176));
            xTick(s) = info.targets(s);
        end
    else
        xTickLabels = cell(nrOfEyePositionsInTesting,1);
        xTick = zeros(nrOfEyePositionsInTesting,1);
        for s=1:nrOfEyePositionsInTesting,
            %s = sprintf('45%c', char(176));
            %xTickLabels{s} = [num2str(info.eyePositions(s)) '^{\circ}'];

            xTickLabels{s} = sprintf([num2str(info.eyePositions(s)) '%c'], char(176));
            xTick(s) = info.eyePositions(s);
        end
    end
    
    % Iterate regions to do correlation plot and setup callbacks
    fig = figure('name',filename,'NumberTitle','off');
    for r=2:numRegions
        
        %{
        % Delta plot
        % Figure out what cells we have history for!!!!!, put it here!, all
        % other cells we just gray out
        %axisVals(r-1,1) = subplot(numRegions, PLOT_COLS, PLOT_COLS*(r-2) + 1); % Save axis
        %deltaMatrix = rand(10,10);% painstakingly slow regionDelta(network_1, network_2, r);
        %im = imagesc(deltaMatrix);
        %daspect([size(deltaMatrix) 1]);
        %title('This vs. BlankNetwork weight matrix correlation per cell');
        %colorbar;
        %set(im, 'ButtonDownFcn', {@singleUnitCallBack, r}); % Setup callback
        %}
        
        axisVals(r-1,1) = subplot(numRegions, PLOT_COLS, PLOT_COLS*(r-2) + 1); % Save axis
        
        if thereIsSingleUnitRecording,
            
            height = networkDimensions(r).y_dimension;
            width = networkDimensions(r).x_dimension;
            v2 = reshape([singleUnits{r}(:, :, 1).isPresent],[height width]);
            im = imagesc(v2);
            daspect([size(v2) 1]);
            title(['Recorded Units in Region: ' num2str(r)]);
            colorbar;
            set(im, 'ButtonDownFcn', {@singleUnitCallBack, r}); % Setup callback
        end
        
        if ~isempty(data),%{r-1}),
            
            % Activity indicator
            axisVals(r-1,2) = subplot(numRegions, PLOT_COLS, PLOT_COLS*(r-2) + 2); % Save axis

            % TRADITIONAL
            %{ 
            im = imagesc(regionCorrs{r-1});
            title('Head centerede correlation');
            %}

            % SIMON
            %{
            v0 = data;%{r-1};
            v0(v0 > 0) = 1;  % count all nonzero as 1, error terms have already been removed
            
            
            % Fix when only one object in Simon Mode
            if objectsPrEyePosition > 1,
                v1 = squeeze(sum(sum(v0))); % sum away
            else
                v1 = squeeze(sum(v0)); % sum away
            end
            
            v2 = v1(:,:,1);
            %im = imagesc(v2);         % only do first region
            %}
            im = imagesc(analysisResults.headCenteredNess);
            %daspect([size(v2) 1]);
            %title('Number of testing locations responded to');
            title('\lambda');
            colorbar;
            
            % ResponseCount historgram
            axisVals(r-1,3) = subplot(numRegions, PLOT_COLS, PLOT_COLS*(r-2) + 3); % Save axis
            hist(hmatTOP,50);
            
            %noZeros = v2(:);
            %noZeros(noZeros == 0) = [];
            %hist(noZeros,1:(max(max(v2))));
            %title(['Mean: ' num2str(mean2(v2))]);
            set(im, 'ButtonDownFcn', {@responseCallBack, r}); % Setup callback
            
            

            
            % Invariance heuristic
            axisVals(r-1,PLOT_COLS) = subplot(numRegions, PLOT_COLS, PLOT_COLS*(r-2) + PLOT_COLS); % Save axis

            plot(analysisResults.RFLocation_Linear, analysisResults.headCenteredNess_Linear, 'ob');
            hold on;
            
            %scatterAxis = herrorbar(analysisResults.RFLocation_Linear_Clean, analysisResults.headCenteredNess_Linear_Clean, analysisResults.RFLocation_Confidence_Linear_Clean , 'or'); %, 'LineWidth', 2
            scatterAxis = plot(analysisResults.RFLocation_Linear_Clean, analysisResults.headCenteredNess_Linear_Clean, 'or', 'LineWidth', 2);

            %scatterAxis = plot(hmat,lmat,'o');
            set(scatterAxis, 'ButtonDownFcn', @scatterCallBack); % Setup callback
            ylim([-0.1 1]);
            
            %{
            responseCounts = invarianceHeuristics(filename, nrOfEyePositionsInTesting);

            bar(responseCounts);
            %}
            
            %{
            % Plot a line for each object
            %for e=1:nrOfEyePositionsInTesting,
            %    plot(responseCounts{e}, ['-' markerSpecifiers{e}], 'Linewidth', PLOT_COLS);
            %    hold all
            %end

            %axis tight
            %legend(objectLegend);
            %}

            hold off
        else
            subplot(numRegions, PLOT_COLS, PLOT_COLS*(r-2) + 2); % Save axis
            subplot(numRegions, PLOT_COLS, PLOT_COLS*(r-2) + 3); % Save axis
            subplot(numRegions, PLOT_COLS, PLOT_COLS*(r-2) + PLOT_COLS); % Save axis
        end
    end
    
    makeFigureFullScreen(fig);
    
    % Callback
    function responseCallBack(varargin)
        
        % Extract region,row,col
        region = varargin{3};

        pos = get(axisVals(region-1,2), 'CurrentPoint');
        [row, col] = imagescClick(pos(1, 2), pos(1, 1), networkDimensions(region).y_dimension, networkDimensions(region).x_dimension);

        responseClick(row,col,region)
    end

    function responseClick(row,col,region)
        
        disp(['Row,Col: ' num2str(row) ',' num2str(col)]);
        disp(['lambda: ' num2str(analysisResults.headCenteredNess(row,col))]);
        disp(['h-value: ' num2str(analysisResults.RFLocation(row,col))]);
        disp(['psi: ' num2str(analysisResults.RFSize(row,col))]);
        
        % single left  click => 'SelectionType' = 'normal'
        % single right click => 'SelectionType' = 'alt'
        % double right click => 'SelectionType' = 'open'
        clickType = get(gcf,'SelectionType');
        
        if strcmp(clickType,'normal'),
            
            % Dump correlation
            %disp(['Correlation: ' num2str(regionCorrs{region-1}(row,col))]);

            % Setup blank plot
            axisVals(numRegions, [1 PLOT_COLS]) = subplot(numRegions, PLOT_COLS, [PLOT_COLS*(numRegions - 1) + 1 PLOT_COLS*(numRegions - 1) + PLOT_COLS]);

            cellData = data(:, :, row, col); % {region-1}
            plot(cellData');
            
            ylim([-0.1 1.1]);
            xlim([1 objectsPrEyePosition]);
            
        elseif strcmp(clickType,'alt'),
                
            %Right click
            [path, name, ext] = fileparts(filename);
            [path, name, ext] = fileparts(path);
            
            trainingFolder = [path '/Training'];
            
            plotSynapseHistory(trainingFolder, region, 1, row, col,1);
        else
            showWeights(networkFile, networkDimensions, neuronOffsets, region, row, col, 1); %depth
            prettyPlot(region,row,col);
        end 
        
    end

    % Callback 2
    function singleUnitCallBack(varargin)
        
        % Extract region,row,col
        region = varargin{3};

        pos = get(axisVals(region-1,1), 'CurrentPoint');
        [row, col] = imagescClick(pos(1, 2), pos(1, 1), networkDimensions(region).y_dimension, networkDimensions(region).x_dimension);

        if singleUnits{region}(row, col, 1).isPresent,
            responseClick(row,col,region);
            plotSingleUnit(singleUnits{region}(row, col, 1), historyDimensions);
            
        else
            disp('Not recorded.');
        end
        
    end

    function scatterCallBack(varargin)
        
        pos = get(gca,'Currentpoint'); %get(scatterAxis, 'CurrentPoint');
        %[row, col] = imagescClick(pos(1, 2), pos(1, 1), networkDimensions(region).y_dimension, networkDimensions(region).x_dimension);
        
        hvalueClick = pos(1,1);
        lambdaClick = pos(1,2);
        
        % Find neuron with closest match
        d = [ones(length(scatterSpace),1)*lambdaClick ones(length(scatterSpace),1)*hvalueClick];
        
        error = sum(((scatterSpace - d).^2)');
        
        [e leastErrorIndex] = min(error);
        
        [row col] = ind2sub(size(analysisResults.headCenteredNess), leastErrorIndex);

        % Update response plot
        responseClick(row,col,2)
        
    end

    function prettyPlot(region,row,col)

        % Get single cell score
        sCell = analysisResults.headCenteredNess(row, col);
        cellNr = (row-1)*topLayerRowDim + col;
        response = data(:, :, row, col);
        y = squeeze(response);
        
        
        figure();
        imagesc(y');
        
        
        %{
        figure();
        x = info.targets;
        y = info.eyePositions;

        v = response;

        [xq,yq] = meshgrid(info.targets(1):0.1:info.targets(end), info.eyePositions(1):0.1:info.eyePositions(end));

        vq = griddata(x,y,v,xq,yq);

        mesh(xq,yq,vq);
        hold on
        
        [xq2,yq2] = meshgrid(info.targets, info.eyePositions);
        %plot3(xq2(:),yq2(:),response(:),'o');
        %}
        
        %{
        figure();
        [xq,yq] = meshgrid(info.targets, info.eyePositions); 
        mesh(xq,yq,response);
        %}
        
        %{
        % Dialogs
        answer = inputdlg('Qualifier')

        if ~isempty(answer)
            qualifier = ['-' answer{1}];
        else
            qualifier = '';
        end
        %}
        
        %{

        if doHeadCentered,
            
            for h = 1:nrOfEyePositionsInTesting,
                
                f = figure();

                y = squeeze(data{region-1}(h, :, row, col));

                %if doHeadCentered,
                    % head centere refrernce frame
                    x = info.targets;
                %else
                    % retinal reference frame
                    %x = info.targets - info.eyePositions(h);
                %end

                % color
                
                %c = mod(e-1,length(colors)) + 1;
                
                %plot(x,y, ['-k' markerSpecifiers{h}]);
                %colors{c}
                plot(x,y,'-bd','LineWidth',2,'MarkerSize',8);
                
                %hold all;

                hTitle = title('')%; title(['Fixating ' num2str(info.eyePositions(h)) '^{\circ}']); % ', R:' num2str(region) % ', \Omega_{' num2str(cellNr) '} = ' num2str(sCell)
                %axis([min(info.targets) max(info.targets) -0.1 1.1]);
                %hLegend = legend(objectLegend);
                %legend('boxoff')
                hYLabel = ylabel('Firing rate');
                hXLabel = xlabel('Head-centered location (deg)');
                
                set( gca                       , ...
                    'FontName'   , 'Helvetica' );
                set([hTitle, hXLabel, hYLabel], ...
                    'FontName'   , 'AvantGarde');
                set(gca             , ...
                    'FontSize'   , 28           );
                set([hXLabel, hYLabel]  , ...
                    'FontSize'   , 28          );
                set( hTitle                    , ...
                    'FontSize'   , 32          , ...
                    'FontWeight' , 'bold'      );

                set(gca, ...
                  'Box'         , 'on'     , ...
                  'TickDir'     , 'in'     , ...
                  'TickLength'  , [.02 .02] , ...
                  'XMinorTick'  , 'off'     , ...
                  'YMinorTick'  , 'off'      , ...
                  'YGrid'       , 'off'      , ...
                  'YTick'       , 0:0.2:1, ...
                  'LineWidth'   , 2         );

                %'XColor'      , [.3 .3 .3], ...
                %'YColor'      , [.3 .3 .3], ...     

                set(gca,'YLim',[-0.1 1.1]);
                %set(gca,'XTick',1:nrOfBins);
                
                set(gca,'XTick', xTick);
                set(gca,'XTickLabel', xTickLabels);
                
                xlim([(xTick(1)-0.5) (xTick(end)+0.5)]);
                
                % SAVE
                chap = 'chap-2';
                fname = [THESIS_FIGURE_PATH chap '/neuron_response_' num2str(h) '_' num2str(cellNr) qualifier '.eps'];
                set(gcf,'renderer','painters');
                print(f,'-depsc2','-painters',fname);
                
            end
            
            %hXLabel = xlabel('Head-centered location (deg)');
        else
            %{
            
            f = figure();
        
            for o = 1:objectsPrEyePosition,

                y = squeeze(data{region-1}(:, o, row, col));
                x = info.eyePositions;
                
                c = mod(o-1,length(colors)) + 1;

                plot(x,y,['-' markerSpecifiers{c}],'LineWidth',2,'MarkerSize',8);

                hold all;
            end
            
            set(gca,'XTick', xTick);
            set(gca,'XTickLabel', xTickLabels);

            hXLabel = xlabel('Fixation location (deg)');
            hLegend = legend(objectLegend);
            set([hLegend, gca]             , ...
            'FontSize'   , 14           );
        
            hTitle = title('');
           % hTitle = title(['Cell #' num2str(cellNr)]); % ', R:' num2str(region) % ', \Omega_{' num2str(cellNr) '} = ' num2str(sCell)
            %axis([min(info.targets) max(info.targets) -0.1 1.1]);

            legend('boxoff')
            hYLabel = ylabel('Firing rate');

            set( gca                       , ...
                'FontName'   , 'Helvetica' );
            set([hTitle, hXLabel, hYLabel], ...
                'FontName'   , 'AvantGarde');
            set([hXLabel, hYLabel]  , ...
                'FontSize'   , 28          );
            set( hTitle                    , ...
                'FontSize'   , 32,           ...
                'FontWeight' , 'bold'      );
            set( gca             , ...
                'FontSize'   , 28           );

            set(gca, ...
              'Box'         , 'on'     , ...
              'TickDir'     , 'in'     , ...
              'TickLength'  , [.02 .02] , ...
              'XMinorTick'  , 'off'     , ...
              'YMinorTick'  , 'off'      , ...
              'YGrid'       , 'off'      , ...
              'YTick'       , 0:0.2:1, ...
              'LineWidth'   , 2         );

            %'XColor'      , [.3 .3 .3], ...
            %'YColor'      , [.3 .3 .3], ...     

            set(gca,'YLim',[-0.1 1.1]);
            %set(gca,'XTick',1:nrOfBins);
            
            % SAVE
            chap = 'chap-2';
            fname = [THESIS_FIGURE_PATH chap '/neuron_response_m_' num2str(cellNr) '.eps'];
            set(gcf,'renderer','painters');
            print(f,'-depsc2','-painters',fname);
            
            %}
        
        end
        
        %}
       
    end
    
end