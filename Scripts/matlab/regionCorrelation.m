%
%  regionCorrelation.m
%  SMI
%
%  Created by Bedeho Mender on 15/11/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%

function [regionCorrelation] = regionCorrelation(filename, nrOfEyePositionsInTesting)

    % Get dimensions
    [networkDimensions, historyDimensions] = getHistoryDimensions(filename);
    
    % Load data
    [data, objectsPrEyePosition] = regionDataPrEyePosition(filename, nrOfEyePositionsInTesting);
    
    % Setup vars
    numRegions = length(networkDimensions);
    regionCorrelation = cell(numRegions-1,1);
    
    % Compute correlation for each region
    for r=2:numRegions,
        
        dataPrEyePosition = data{r-1,1};
        
        y_dimension = networkDimensions(r).y_dimension;
        x_dimension = networkDimensions(r).x_dimension;
        regionCorrelation{r-1} = zeros(y_dimension, x_dimension);
        
        % Compute correlation for each cell
        for row = 1:y_dimension,
            for col = 1:x_dimension,

                corr = 0;

                for eyePosition = 1:(nrOfEyePositionsInTesting - 1),

                    observationMatrix = [dataPrEyePosition(:, eyePosition,row,col) dataPrEyePosition(:, eyePosition+1,row,col)];

                    if isConstant(observationMatrix(:, 1)) || isConstant(observationMatrix(:, 2)),
                        c = 0; % uncorrelated
                    else

                        % correlation
                        correlationMatrix = corrcoef(observationMatrix);
                        c = correlationMatrix(1,2); % pick one of the two identical non-diagonal element :)

                    end

                    corr = corr + c;
                end

                regionCorrelation{r-1}(row, col) = corr / (nrOfEyePositionsInTesting - 1); % average correlation
            end
        end
    end
    
    function [test] = isConstant(arr)
        
        test = isequal(arr(1) * ones(length(arr),1), arr);
    