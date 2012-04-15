%
%  inspectWeights.m
%  SMI
%
%  Created by Bedeho Mender on 29/04/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%

function inspectWeights(networkFile, filename, nrOfEyePositionsInTesting)
        
    % Load data
    [networkDimensions, neuronOffsets] = loadWeightFileHeader(networkFile); % Load weight file header
    [data, objectsPrEyePosition] = regionDataPrEyePosition(filename, nrOfEyePositionsInTesting); % (object, eye_position, row, col, region)
    
    % Setup vars
    numRegions = length(networkDimensions);
    axisVals = zeros(numRegions-1, 3); % Save axis that we can lookup 'CurrentPoint' property on callback
    
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
        
        drawWeights(region, row, col, 1);
        
        if region == 2,
            drawWeights(region, row, col, 2);
        end
        
    end

    function drawWeights(region, row, col, sourceDepth)
        
        % Plot the two input layers
        subplot(numRegions-1, 3, 3*(region-2) + 1 + sourceDepth);
        weightBox1 = afferentSynapseMatrix(fileID, networkDimensions, neuronOffsets, region, 1, row, col, region-1, sourceDepth);
        cla
        imagesc(weightBox1);
        dim = fliplr(size(weightBox1));
        daspect([dim 1]);
        colorbar;
    end
    
end

