%
%  outputSample.m
%  SMI
%
%  Created by Bedeho Mender on 19/11/12.
%  Copyright 2012 OFTNAI. All rights reserved.
%
%  Purpose: output a sample, vectorized
%

function outputSample(fileID, e, t, samplesPrLocation)

    eyeposition = e*ones(1, samplesPrLocation);
    retinallocation = repmat((t-e)', 1, samplesPrLocation);
    data = [eyeposition; retinallocation];
    
    fwrite(fileID, data(:), 'float');
    fwrite(fileID, NaN('single'), 'float'); % transform flag

    %{
    for sampleCounter = 1:samplesPrLocation,

        %disp(['Saved: eye =' num2str(e) ', ret =' num2str(t - e)]); % head centered data outputted, relationhip is t = r + e
        fwrite(fileID, e, 'float'); % Eye position (HFP)
        fwrite(fileID, t - e, 'float'); % Fixation offset of target
    end

    %disp('object done*******************');
    fwrite(fileID, NaN('single'), 'float'); % transform flag

    %}

end