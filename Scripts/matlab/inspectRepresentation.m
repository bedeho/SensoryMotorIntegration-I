%
%  inspectRepresentation.m
%  SMI
%
%  Created by Bedeho Mender on 29/04/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%

function inspectRepresentation(filename, nrOfEyePositionsInTesting)

    % Get dimensions
    [networkDimensions, historyDimensions] = getHistoryDimensions(filename);
    
    % Load data
    [data, objectsPrEyePosition] = regionDataPrEyePosition(filename, nrOfEyePositionsInTesting); % {region}(object, eye_position, row, col, region)
    
    % Setup vars
    numRegions = length(networkDimensions);

    % Setup activity plot
    fig = figure('name',filename,'NumberTitle','off');
    
    clickAxis = subplot(numRegions, 1, 1);
    
    total = zeros(objectsPrEyePosition, nrOfEyePositionsInTesting);
    for r=1:(numRegions-1),
        v1 = permute(data{r}, [3 4 1 2]); % expose the last two dimensions to be summed away
        v1(v1 > 0) = 1;                   % count nonzero response as 1, all error terms have previously been removed
        v2 = squeeze(sum(sum(v1)));       % sum over all neurons in all regions
        total = total + v2;
    end
    
    im = imagesc(total);
    colorbar;
    title('# responding cells per testing location');
        
    % Setup callback
    set(im, 'ButtonDownFcn', {@responseCallBack});
    
    % Iterate regions to do blank plot
    for r=2:numRegions,
        subplot(numRegions, 1, r);
    end
    
    %makeFigureFullScreen(fig);
    
    % Callback
    function responseCallBack(varargin)
        
        % Extract row,col
        pos = get(clickAxis, 'CurrentPoint');
        [row, col] = imagescClick(pos(1, 2), pos(1, 1), objectsPrEyePosition, nrOfEyePositionsInTesting);
        
        % Response count
        disp(['# responding: ' num2str(total(row,col))]);
        
        % Iterate regions to do response plot
        for r=2:numRegions,
            subplot(numRegions, 1, r);
            m = squeeze(data{r-1}(row, col, :, :));
            cla
            imagesc(m); % > 0
            colorbar
            title(['Layer: ' num2str(r)]);
        end
    end
end
