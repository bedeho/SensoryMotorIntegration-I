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

    % Load stimuli
    startDir = pwd;
    cd([base 'Stimuli/' stimuliName]);
    C = load('info.mat');
    info = C.info;
    cd(startDir);
    
    % Read out analysis results
    [pathstr, name, ext] = fileparts(filename);
    x = load([pathstr '/analysisResults.mat']);
    analysisResults = x.analysisResults;
    
    %figure
    %scatterhist(analysisResults.RFLocation_Linear,analysisResults.headCenteredNess_Linear,'NBins',60);
    
    % Network summary
    disp('************************************************************');
    disp(['fractionVeryHeadCentered: ' num2str(analysisResults.fractionVeryHeadCentered)]);
    disp(['fractionDiscarded: ' num2str(analysisResults.fractionDiscarded)]);
    disp(['fractionDiscarded_Discontinous: ' num2str(analysisResults.fractionDiscarded_Discontinous)]);
    disp(['fractionDiscarded_Edge: ' num2str(analysisResults.fractionDiscarded_Edge)]);
    disp(['fractionDiscarded_MultiPeak: ' num2str(analysisResults.fractionDiscarded_MultiPeak)]);
    %disp(['uniformityOfVeryHeadCentered: ' num2str(analysisResults.uniformityOfVeryHeadCentered)]);
    %disp(['maxEntropy: ' num2str(analysisResults.maxEntropy)]);
    disp(['coverage: ' num2str(analysisResults.uniformityOfVeryHeadCentered/analysisResults.maxEntropy)]);
    disp('************************************************************');
    
    % For scatter
    wellBehavedNeurons  = analysisResults.wellBehavedNeurons;
    scatterSpace = [wellBehavedNeurons(:,6) wellBehavedNeurons(:,3)]; %[analysisResults.RFLocation_Linear , analysisResults.headCenteredNess_Linear ];%  % 
    numInScatter = length(scatterSpace);
    
    % For distribution
    hmatTOP = analysisResults.RFLocation_Linear;
    hmatTOP(analysisResults.headCenteredNess_Linear < 0.7) = [];     % shave out

    % Load single unit recordings
  
    % Decouple name
    [pathstr2, name2, ext2] = fileparts(pathstr);
    %manualData = [pathstr '/singleUnits.dat'];
    trainingData = [pathstr2 '/Training/singleUnits.dat'];
    thereIsSingleUnitRecording = exist(trainingData,'file');
    
    if thereIsSingleUnitRecording,
        %[singleUnits, historyDimensions, nrOfPresentLayers] = loadSingleUnitRecordings(manualData);
        [singleUnits, historyDimensions, nrOfPresentLayers] = loadSingleUnitRecordings(trainingData);    
    end
    
    % Setup vars
    PLOT_COLS = 4;
    numRegions = length(networkDimensions);
    axisVals = zeros(numRegions, PLOT_COLS); % Save axis that we can lookup 'CurrentPoint' property on callback
    colors = {'r', 'b','k','c', 'm', 'y', 'g', 'w'};
    topLayerRowDim = networkDimensions(numRegions).x_dimension;
    
    numEyePositions = length(info.eyePositions);
    
    
    dist = 16;
    upperhalf = dist:dist:(dist*floor(info.targets(1)/dist));
    xTick = [-fliplr(upperhalf) 0 upperhalf];%centerN(floor(info.targets(1) - info.targets(end)),20);
        
    %xTick = centerDistance(info.targets(1) - info.targets(end), 20);
    
    for s=1:length(xTick),
        xTickLabels{s} = sprintf([num2str(xTick(s)) '%c'], char(176));
    end
    
    objectLegend = cell(numEyePositions,1);
    for e=1:numEyePositions,
        objectLegend{e} = ['Fixating ' num2str(info.eyePositions(e)) '^{\circ}'];
    end

    
    % Iterate regions to do correlation plot and setup callbacks
    fig = figure('name',filename,'NumberTitle','off');
    for r=2:numRegions
        
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
            
            im = imagesc(analysisResults.headCenteredNess);
            pbaspect([size(im) 1]);
            title('\lambda');
            colorbar;
            
            set(im, 'ButtonDownFcn', {@imagescCallback, r}); % Setup callback
            
            % ResponseCount historgram
            axisVals(r-1,3) = subplot(numRegions, PLOT_COLS, PLOT_COLS*(r-2) + 3); % Save axis
            
            hist(hmatTOP,50);
            
            % Scatter
            axisVals(r-1,PLOT_COLS) = subplot(numRegions, PLOT_COLS, PLOT_COLS*(r-2) + PLOT_COLS); % Save axis
            
            scatterAxis_BLUE = plot(analysisResults.RFLocation_Linear, analysisResults.headCenteredNess_Linear, 'ob');
            %set(scatterAxis_BLUE, 'ButtonDownFcn', {@scatterCallBack,r}); % Setup callback
            hold on;
            
            %scatterAxis = herrorbar(analysisResults.RFLocation_Linear_Clean, analysisResults.headCenteredNess_Linear_Clean, analysisResults.RFLocation_Confidence_Linear_Clean , 'or'); %, 'LineWidth', 2
            scatterAxis_RED = plot(analysisResults.RFLocation_Linear_Clean, analysisResults.headCenteredNess_Linear_Clean, 'or', 'LineWidth', 1);
            set(scatterAxis_RED, 'ButtonDownFcn', {@scatterCallBack,r}); % Setup callback
            ylim([-0.1 1]);
            xlim([info.targets(end) info.targets(1)]);
            
            hold off
        else
            subplot(numRegions, PLOT_COLS, PLOT_COLS*(r-2) + 2); % Save axis
            subplot(numRegions, PLOT_COLS, PLOT_COLS*(r-2) + 3); % Save axis
            subplot(numRegions, PLOT_COLS, PLOT_COLS*(r-2) + PLOT_COLS); % Save axis
        end
    end
    
    makeFigureFullScreen(fig);
    
    % imagescCallback
    function imagescCallback(varargin)
        
        % Extract region,row,col
        region = varargin{3};

        pos = get(axisVals(region-1,2), 'CurrentPoint');
        [row, col] = imagescClick(pos(1, 2), pos(1, 1), networkDimensions(region).y_dimension, networkDimensions(region).x_dimension);

        viewNeuron(row,col,region);
    end

    function scatterCallBack(varargin)
        
        pos = get(gca,'Currentpoint'); %get(scatterAxis, 'CurrentPoint');
        %[row, col] = imagescClick(pos(1, 2), pos(1, 1), networkDimensions(region).y_dimension, networkDimensions(region).x_dimension);
        
        hvalueClick = pos(1,1);
        lambdaClick = pos(1,2);
        
        % Find neuron with closest match
        d = repmat([hvalueClick lambdaClick], numInScatter, 1);
        
        error = sum(((scatterSpace - d).^2)');
        
        [e leastErrorIndex] = min(error);
        
        %[row col] = ind2sub(size(analysisResults.headCenteredNess), leastErrorIndex);

        row = wellBehavedNeurons(leastErrorIndex,1);
        col = wellBehavedNeurons(leastErrorIndex,2);
        
        % Update response plot
        viewNeuron(row,col,2);
        
    end

    function viewNeuron(row,col,region)
        
        disp(['Row,Col: ' num2str(row) ',' num2str(col)]);
        disp(['lambda: ' num2str(analysisResults.headCenteredNess(row,col))]);
        disp(['h-value: ' num2str(analysisResults.RFLocation(row,col))]);
        disp(['psi: ' num2str(analysisResults.RFSize(row,col))]);
        disp(['Discard:' num2str(analysisResults.DiscardStatus(row,col))]);
        
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
            plot(repmat(info.targets',1,numEyePositions),cellData');
            
            ylim([-0.1 1.1]);
            xlim([info.targets(end) info.targets(1)]);
            set(gca,'XTick', xTick);
            set(gca,'XTickLabel', xTickLabels);
            title(['Row,Col: ' num2str(row) ',' num2str(col)]);
            
            
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

    function prettyPlot(region,row,col)
        
        % Dimensions
        margin = 50;
        fDim = 400;
        sDim = 120;
        tWidth = fDim + 2*margin;
        tHeight = fDim + 2*margin;
        
        % Create figure
        figure('Units','Pixels','position', [1000 1000 tWidth tHeight]);
    
        responsePlot = subplot(1,2,1);
        
        fixationAxes = zeros(1,numEyePositions);
        
        cellData = data(:, :, row, col); % {region-1}
        plot(info.targets,cellData');

        %{
        for e = 1:numEyePositions,

            y = squeeze(data(e, :, row, col));

            c = mod(e-1,length(colors)) + 1;
            
            % Curve
            fixationAxes(e) = plot(info.targets, y,'-','Color',colors{c});
            %plot(y,['-' markerSpecifiers{c}],'Color',colors{c},'MarkerSize',8);
            
            hold on;
            
            % Mean
            meanY = mean(y)
            plot([info.targets(1) info.targets(end)], [meanY meanY], '.--','Color', colors{c});
            hold on;
            
        end
        %}
       
        set(gca,'XTick', xTick);
        set(gca,'XTickLabel', xTickLabels);
        axis square;
        xlim([xTick(1) xTick(end)]);
        ylim([-0.05 1.05]);
        
        ylabel('Firing Rate');
        xlabel('Head-Centered Stimuli Location (deg)');
        
        legend(objectLegend); % fixationAxes
        legend('boxoff');

        cellNr = (row-1)*topLayerRowDim + col
        
        grid

        %hTitle = title(['Cell #' num2str(cellNr)]); % ', R:' num2str(region) % ', \Omega_{' num2str(cellNr) '} = ' num2str(sCell)
        

        % Population plot        
        scatterPlot = subplot(1,2,2);
        
        grey = [0.1 0.1 0.1];
        plot(analysisResults.RFLocation_Linear, analysisResults.headCenteredNess_Linear, 'o', 'MarkerSize' , 1, 'MarkerFaceColor', grey, 'MarkerEdgeColor', grey);
        hold on;
        plot(analysisResults.RFLocation(row,col), analysisResults.headCenteredNess(row,col), 'o', 'MarkerSize' , 3, 'LineWidth', 3, 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'r');
        ylim([-0.1 1]);
        xlim([info.targets(end) info.targets(1)]);
        
        % Turn off ticks
        set(gca,'xtick',[]);
        set(gca,'ytick',[]);
        axis square
        
        p = [margin margin fDim fDim];
        set(responsePlot, 'Units','Pixels', 'pos', p);
        
        p = [(margin+15) (fDim-85) sDim sDim];
        set(scatterPlot, 'Units','Pixels', 'pos', p);
        
        % SAVE
        %{
        chap = 'chap-2';
        fname = [THESIS_FIGURE_PATH chap '/neuron_response_m_' num2str(cellNr) '.eps'];
        set(gcf,'renderer','painters');
        print(f,'-depsc2','-painters',fname);
        %}
        
    end
 

end