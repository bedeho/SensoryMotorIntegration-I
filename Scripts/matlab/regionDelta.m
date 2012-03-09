%
%  regionDelta.m
%  SMI
%
%  Created by Bedeho Mender on 25/02/12.
%  Copyright 2012 OFTNAI. All rights reserved.
%
% prupose: for each cell gives correlation between weightmatrixes provided,
% is meant to help distinguish cells which have had their weights updated and
% cells that have not

function deltaMatrix = regionDelta(network_1, network_2, region)

    % Load headers
    [networkDimensions_1, neuronOffsets_1] = loadWeightFileHeader(network_1);
    [networkDimensions_2, neuronOffsets_2] = loadWeightFileHeader(network_2);
    
    
    %if networkDimensions_1 ~= networkDimensions_2 || neuronOffsets_1 ~= neuronOffsets_2,
    %    error('Incompatible networks');
    %end
    
    % Open both networks
    fileID_1 = fopen(network_1);
    fileID_2 = fopen(network_2);
    
    % Allocate space
    x_dimensions = networkDimensions_1(region).x_dimension;
    y_dimensions = networkDimensions_1(region).y_dimension;
    
    deltaMatrix = zeros(x_dimensions, y_dimensions);
    
    % Iterate cells and save correlation
    for row=1:y_dimensions,
        for col=1:x_dimensions,
            
            synapses_1 = afferentSynapseList(fileID_1, neuronOffsets_1, region, 1, row, col);
            synapses_2 = afferentSynapseList(fileID_2, neuronOffsets_2, region, 1, row, col);
            
            col_1 = [synapses_1(:).weight];
            col_2 = [synapses_2(:).weight];
            
            X = [col_1' col_2'];
            
            corr = corrcoef(X);
            
            deltaMatrix(row,col) = corr(1,2);
        end
    end
    
    % Close files
    fclose(fileID_1);
    fclose(fileID_2);
    
end