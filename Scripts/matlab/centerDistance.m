%
%  centerDistance.m
%  SMI
%
%  Created by Bedeho Mender on 15/11/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%
%  Purpose: Create data points evenly distanced and centered around 0

function [v] = centerDistance(width, distance)
    
    v = -width/2:distance:width/2;
    v = v - (v(1) + v(end)) / 2; % shift approprite amount in the right direction to center