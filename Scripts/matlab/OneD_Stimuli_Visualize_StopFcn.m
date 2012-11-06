%
%  OneD_Stimuli_Visualize_StopFcn.m
%  SMI
%
%  Created by Bedeho Mender on 15/11/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%

%  Purpose: StopFcn callback
function OneD_Stimuli_Visualize_StopFcn(obj, event)

    global OneD_Stimuli_VisualizeTimeObject;
    
    % Delete timer
    delete(OneD_Stimuli_VisualizeTimeObject);
end