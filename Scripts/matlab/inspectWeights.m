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
    
    % Load TRAINING stimuli
    trainingStimuliName = strrep(stimuliName, '-stdTest', '-training');
    
    startDir = pwd;
    cd([base 'Stimuli/' trainingStimuliName]);
    dimensions = load('dimensions.mat');
    cd(startDir);
    
    % Setup vars
    numRegions = length(networkDimensions);
    axisVals = zeros(numRegions-1, 3); % Save axis that we can lookup 'CurrentPoint' property on callback
    topLayerRowDim = networkDimensions(numRegions).x_dimension;
    
    visualPreferenceDistance            = 1;
    eyePositionPrefrerenceDistance      = 1;
    visualPreferences                   = fliplr(centerDistance(dimensions.visualFieldSize, visualPreferenceDistance));
    eyePositionPreferences              = centerDistance(dimensions.eyePositionFieldSize, eyePositionPrefrerenceDistance);

    % Iterate regions to do correlation plot and setup callbacks
    fig = figure('name',filename,'NumberTitle','off');
    title('Number of testing locations responded to');
    
    % Read out analysis results
    [pathstr, name, ext] = fileparts(filename);
    
    x = load([pathstr '/analysisResults.mat']);
    
    analysisResults = x.analysisResults;
    
    for r=2:numRegions
        
        % Save axis
        clickAxis(r-1,1) = subplot(numRegions-1, 3, 3*(r-2)+1);
        
        % Decorate
        title(['Region: ' num2str(r)]);
        im = imagesc(analysisResults.headCenteredNess);         % only do first region
        pbaspect([fliplr(size(im)) 1]);
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
        disp(['row,col =' num2str(row) ',' num2str(col)]);
        
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
        % wrong: disp(['Number of synapses from this depth from this region: ' num2str(numel(weightBox1))]);
        cla
        imagesc(weightBox1);
        dim = fliplr(size(weightBox1));
        pbaspect([dim 1]);
        colorbar;
        
        [height,width] = size(weightBox1);
        
        % External figure
        if rightClicked,
            
            figure('Units','Pixels','position', [1000 1000 300 500]);
            
            % Plot
            imagesc(weightBox1);
            dim = fliplr(size(weightBox1));
            pbaspect([dim 1]);
            colorbar

            %hTitle = title(''); %; title(['Afferent synaptic weights of cell #' num2str(cellNr) extraTitle]);
            hYLabel = ylabel('Retinal preference (deg)'); % : \alpha_{i}
            hXLabel = xlabel('Eye-position preference (deg)'); % : \beta_{i}
            
            cellNr = (row-1)*topLayerRowDim + col;
            disp(['Cell: ' num2str(cellNr)]);
            disp(['Number of Afferent synapses: ' num2str(nnz(weightBox1 > 0))]);
          
            % Fix axes ticks
            
            wTicks = 1:width;
            wdist = 15;
            wTicks = wTicks(1:wdist:end);
            wLabels = eyePositionPreferences(1:wdist:end);
            wCellLabels = cell(1,length(wLabels));
            for t=1:length(wLabels),
              wCellLabels{t} = num2str(wLabels(t));
            end
            
            set(gca,'XTick',wTicks);
            set(gca,'XTickLabel',wCellLabels);
            
            % Height
            hTicks = 1:height;
            hdist = 20;
            hTicks = hTicks(1:hdist:end);
            hLabels = visualPreferences(1:hdist:end);
            hCellLabels = cell(1,length(hLabels));
            for l=1:length(hLabels),
              hCellLabels{l} = [num2str(hLabels(l)) ];
            end

            set(gca,'YTick',hTicks);
            set(gca,'YTickLabel',hCellLabels);
            
            % Change font size
            set([hYLabel hXLabel], 'FontSize', 16);
            set(gca, 'FontSize', 14);
            
        end
    end
end