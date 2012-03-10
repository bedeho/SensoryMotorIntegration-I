%
%  regionOrthogonality.m
%  SMI
%
%  Created by Bedeho Mender on 28/11/12.
%  Copyright 2012 OFTNAI. All rights reserved.
%

function [outputPatterns,orthogonalityIndex, inputCorrelations, outputCorrelations] = regionOrthogonality(filename, nrOfEyePositionsInTesting, dotproduct, region)

    % Get dimensions
    [networkDimensions, nrOfPresentLayers, historyDimensions] = getHistoryDimensions(filename);
    
    y_dimension = networkDimensions(region).y_dimension;
    x_dimension = networkDimensions(region).x_dimension;
    
    % Load data
    [data, objectsPrEyePosition] = regionDataPrEyePosition(filename, nrOfEyePositionsInTesting);
    
    dataPrEyePosition = data{region-1,1}; % (object, eye_position, row, col, region)
    
    objectsFound = (objectsPrEyePosition * nrOfEyePositionsInTesting);
    
    objectified = reshape(dataPrEyePosition, [objectsFound y_dimension x_dimension]); % (objectified row col)
    
    dotproduct2 = zeros(objectsFound, objectsFound);
    outputPatterns = zeros(objectsFound, objectsFound);
    
    % Iterate all output patterns
    for o1 = 1:objectsFound,
        
        o1
        for o2 = 1:objectsFound,
            
            % Pick output patterns
            v1 = squeeze(objectified(o1, :, :));
            v2 = squeeze(objectified(o2, :, :));
            
            % Normalized dot product
            dotproduct2(o1,o2) = dot(v1(:),v2(:)) / (norm(v1(:)) * norm(v2(:)));
            outputPatterns(o1,o2) = dotproduct2(o1,o2);
            
            % RESET SELF CORRELATIONS
            if o1 == o2,
                dotproduct2(o1,o2) = -1;
                dotproduct(o1,o2) = -1;
            end

        end
    end
    
    % Column wise vectorization
    outputCorrelations = dotproduct2(:);
    inputCorrelations = dotproduct(:);
    
    % Remove selfcorrelations
    outputCorrelations(outputCorrelations == -1) = [];
    inputCorrelations(inputCorrelations == -1) = [];
    
    % Return values
    orthogonalityIndex = mean(outputCorrelations)/mean(inputCorrelations);