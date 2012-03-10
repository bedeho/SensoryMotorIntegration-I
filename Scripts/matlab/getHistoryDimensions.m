%
%  getHistoryDimensions.m
%  SMI
%
%  Created by Bedeho Mender on 15/11/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%

function [networkDimensions, nrOfPresentLayers, historyDimensions] = getHistoryDimensions(filename)

    % Read header
    [networkDimensions, nrOfPresentLayers, historyDimensions, neuronOffsets] = loadHistoryHeader(filename);