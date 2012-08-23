%
%  inspectWeights.m
%  SMI
%
%  Created by Bedeho Mender on 29/04/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%

function inspectWeights(networkFile, filename, nrOfEyePositionsInTesting, stimuliName)
    
    declareGlobalVars();
    
    global base;
    
    % Load data
    [networkDimensions, neuronOffsets] = loadWeightFileHeader(networkFile); % Load weight file header
    [data, objectsPrEyePosition] = regionDataPrEyePosition(filename, nrOfEyePositionsInTesting); % (object, eye_position, row, col, region)
    
    % MaxDepth
    
    
    % Load stimuli
    startDir = pwd;
    cd([base 'Stimuli/' stimuliName]);
    C = load('info.mat');
    info = C.info;
    cd(startDir);
    
    
    % Setup vars
    numRegions = length(networkDimensions);
    axisVals = zeros(numRegions-1, 3); % Save axis that we can lookup 'CurrentPoint' property on callback
    topLayerRowDim = networkDimensions(numRegions).x_dimension;
    
    % Iterate regions to do correlation plot and setup callbacks
    fig = figure('name',filename,'NumberTitle','off');
    title('Number of testing locations responded to');
    
    for r=2:numRegions
        
        % Save axis
        clickAxis(r-1,1) = subplot(numRegions-1, 3, 3*(r-2)+1);
        
        % Plot
        if ~isempty(data{r-1})
            v0 = data{r-1};
            v0(v0 > 0) = 1;  % count all nonzero as 1, error terms have already been removed
            
            % Fix when only one object in Simon Mode
            if objectsPrEyePosition > 1,
                v1 = squeeze(sum(sum(v0))); % sum away
            else
                v1 = squeeze(sum(v0)); % sum away
            end

            v2 = v1(:,:,1);

        else
            v2 = zeros(networkDimensions(r).y_dimension, networkDimensions(r).x_dimension);
        end
        
        % Decorate
        title(['Region: ' num2str(r)]);
        im = imagesc(v2);         % only do first region
        daspect([size(v2) 1]);
        colorbar;
        
        % Setup callback
        set(im, 'ButtonDownFcn', {@responseCallBack, r});
    end
    
    % Keep open for callback
    fileID = fopen(networkFile);
    
    % Callback
    function responseCallBack(varargin)
        
        % Extract region,row,col
        region = varargin{3};
        
        pos = get(clickAxis(region-1,1), 'CurrentPoint');
        [row, col] = imagescClick(pos(1, 2), pos(1, 1), networkDimensions(region).y_dimension, networkDimensions(region).x_dimension);
        
        % Response count
        disp(['# responding: ' num2str(v2(row,col))]);
        
        % Check if we right clicked
        rightClicked =  strcmp(get(gcf,'SelectionType'),'alt');
        
        drawWeights(region, row, col, 1, rightClicked);
        
        if region == 2 && networkDimensions(1).depth > 1,
            drawWeights(region, row, col, 2, rightClicked);
        end
        
    end

    function drawWeights(region, row, col, sourceDepth,rightClicked)
        
        % Plot the two input layers
        subplot(numRegions-1, 3, 3*(region-2) + 1 + sourceDepth);
        weightBox1 = afferentSynapseMatrix(fileID, networkDimensions, neuronOffsets, region, 1, row, col, region-1, sourceDepth);
        cla
        imagesc(weightBox1);
        dim = fliplr(size(weightBox1));
        daspect([dim 1]);
        colorbar;
        axis square;
        
        [height,width] = size(weightBox1);
        
        % External figure
        if rightClicked,
            
            answer = inputdlg('Extra Title')
            
            if ~isempty(answer)
                extraTitle = [' - ' answer{1}];
            else
                extraTitle = '';
            end
            
            f = figure();
            imagesc(weightBox1);
            dim = fliplr(size(weightBox1));
            daspect([dim 1]);
            colorbar;
            hTitle = title(['Afferent synaptic weights of cell #' num2str((row-1)*topLayerRowDim + col) extraTitle]);
            
            hXLabel = xlabel('Eye-position preference: \beta_{i} (deg)');
            hYLabel = ylabel('Retinal preference: \alpha_{i} (deg)');
            
            set( gca                       , ...
                'FontName'   , 'Helvetica' );
            set([hTitle, hXLabel, hYLabel], ...
                'FontName'   , 'AvantGarde');
            set(gca             , ...
                'FontSize'   , 8           );
            set([hXLabel, hYLabel]  , ...
                'FontSize'   , 10          );
            set( hTitle                    , ...
                'FontSize'   , 12          , ...
                'FontWeight' , 'bold'      );
            
            set(gca, ...
              'Box'         , 'on'     , ...
              'TickDir'     , 'out'     , ...
              'TickLength'  , [.01 .01] , ...
              'XMinorTick'  , 'off'    );
          
            % Unbelievable: cannot
            % find matlab command to turn vector into string
            % must do it manually
            
            % Width
            wTicks = 1:width;
            wTicks = wTicks(1:4:end);
            wLabels = info.eyePositionPreferences(1:4:end);
            wCellLabels = cell(1,length(wLabels));
            for l=1:length(wLabels),
              wCellLabels{l} = num2str(wLabels(l));
            end

            set(gca,'XTick',wTicks);
            set(gca,'XTickLabel',wCellLabels);
            
            % Height
            hTicks = 1:height;
            hTicks = hTicks(1:10:end);
            hLabels = info.visualPreferences(1:10:end);
            hCellLabels = cell(1,length(hLabels));
            for l=1:length(hLabels),
              hCellLabels{l} = num2str(hLabels(l));
            end

            set(gca,'YTick',hTicks);
            set(gca,'YTickLabel',hCellLabels);
        end
    end
    
end

