%
%  OneDVisualize_StopFcn.m
%  SMI
%
%  Created by Bedeho Mender on 15/11/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%

%  Purpose: StopFcn callback
function OneDVisualize_StopFcn(obj, event)

    global OneDVisualizeTimeObject;
    
    % Delete timer
    delete(OneDVisualizeTimeObject);
end