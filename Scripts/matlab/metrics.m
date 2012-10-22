%
%  metrics.m
%  SMI
%
%  Created by Bedeho Mender on 15/11/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%

function [headCenteredNess RFSize RFLocation DiscardStatus] = metrics(filename, info)

    % Get dimensions
    [networkDimensions, nrOfPresentLayers, historyDimensions] = getHistoryDimensions(filename);
    
    % Load data
    nrOfEyePositionsInTesting = length(info.eyePositions);
    [data, objectsPrEyePosition] = regionDataPrEyePosition(filename, nrOfEyePositionsInTesting);
    
    % Setup vars
    ratio = 0.5;
    dataPrEyePosition = data;
    
    numRegions = length(networkDimensions);
    y_dimension = networkDimensions(numRegions).y_dimension;
    x_dimension = networkDimensions(numRegions).x_dimension;

    headCenteredNess = zeros(y_dimension, x_dimension);
    RFSize = zeros(y_dimension, x_dimension);
    RFLocation = zeros(y_dimension, x_dimension);
    DiscardStatus = zeros(y_dimension, x_dimension);
    
    targets = info.targets;
    eyePositions = info.eyePositions;
    
    %offset = targets(1);
    delta = targets(2) - targets(1);

    % Compute metrics
    if networkDimensions(numRegions).isPresent,
        
        % Iterate cells
        for row = 1:y_dimension,
            for col = 1:x_dimension,
                
                headCenteredNess(row, col) = computeHeadCenteredNess(row,col);
                
                [psi rfSTDEV maxNumIntervals] = computeRFSize(row,col);
                RFSize(row, col) = psi;
                
                save error decoding
                save discading
                
                
                RFLocation(row, col) = computeRFLocation(row,col);
                DiscardStatus(row,col) = discardStatus(row,col);

            end
        end
    else
        error('Last layer is not present!');
    end
    
    function discard = discardStatus(row,col)
        
        peakResponse = ratio*max(max(dataPrEyePosition(:,:,row,col)));
        response = dataPrEyePosition(:,:,row,col)';
        discard = false;

        % Discontinous rf: there is an eye position for which it is non-respnse ($r_i =0$) to all retinal locations 
        discard = discard || any(sum(response > 0) == 0);
        
        % Edge bias: there is an eye position for which the firing rate ($r_i$) is above the cut off in at least one of the two most eccentric retinal locations
        discard = discard || response(1,:) > peakResponse || response(end,:) > peakResponse;
        
        % Multi peaked:
        discard = discard || ...;
        
    end
    
    function lambda = computeHeadCenteredNess(row,col)
        
        corr = 0;
        combinations = 0;
        
        peakResponse = ratio*max(max(dataPrEyePosition(:,:,row,col)));

        % Iterate all combinations of eye positions
        for ep_1 = 1:(nrOfEyePositionsInTesting - 1),
            for ep_2 = (ep_1+1):nrOfEyePositionsInTesting,

                %{
                %Classic
                observationMatrix = [dataPrEyePosition(ep_1,:,row,col)' dataPrEyePosition(ep_2,:,row,col)'];
                correlationMatrix = corrcoef(observationMatrix);
                c = correlationMatrix(1,2); % pick one of the two identical non-diagonal element :)
                %}
                
                c = dot(dataPrEyePosition(ep_1,:,row,col) - peakResponse,dataPrEyePosition(ep_2,:,row,col) - peakResponse)/(objectsPrEyePosition*(peakResponse*(1-ratio))^2);
                
                corr = corr + c;
                combinations = combinations + 1;

            end
        end
        
        lambda = corr / combinations;
    end

    function [psi rfSTDEV maxNumIntervals] = computeRFSize(row,col)
        
        maxNumIntervals = 0;
        receptiveFieldSizes = zeros(1,nrOfEyePositionsInTesting);
        peakResponse = 0.5*max(max(dataPrEyePosition(:,:,row,col)));
        
        % Iterate all combinations of eye positions
        for e = 1:nrOfEyePositionsInTesting,
            
            intervals = findIntervals(dataPrEyePosition(e, :,row,col), 0, delta, peakResponse); % (interval bounds [a,b],interval)
            
            subReceptiveFieldSizes = diff(intervals);
            
            receptiveFieldSizes(e) = sum(subReceptiveFieldSizes);
            
            [num q] = size(intervals);
            maxNumIntervals = max(maxNumIntervals, num);
            
        end
        
        psi = mean(receptiveFieldSizes);
        rfSTDEV = std(receptiveFieldSizes);
        
    end   
    
    function [h residue] = computeRFLocation(row,col)
        
        %1) Find all centers of mass
        centersOfMass = zeros(1,nrOfEyePositionsInTesting);
        
        for e=1:nrOfEyePositionsInTesting,
            
            responses = dataPrEyePosition(e, :,row,col);
            centersOfMass(e) = dot(responses,targets) / sum(responses);
        end
        
        % Remove any nan entries, that is eye position where there was NO
        % response at all
        
        usedEyePositions = eyePositions;
        usedEyePositions(isnan(centersOfMass)) = [];
        centersOfMass(isnan(centersOfMass)) = [];
        
        %2) Do regression to find best fitting: ax+b
        
        if(length(usedEyePositions) > 1)
        
            p = polyfit(usedEyePositions,centersOfMass,1);
            a = p(1);
            b = p(2);

            %3) Deduce best fitting x+h for ax+b
            h = b - (1-a)/length(usedEyePositions)*sum(usedEyePositions);
            
            %4) fit
            R = corrcoef(usedEyePositions,centersOfMass);
            residue = 1-R(1,2);
        else
            h = NaN;
            residue = NaN;
        end
    end

%{
    function psi = computePsi(row,col)

        f = zeros(1,nrOfEyePositionsInTesting);

        % Iterate all combinations of eye positions
        for k = 1:nrOfEyePositionsInTesting,

            v = dataPrEyePosition(k,:,row,col);
            f(k) = nnz(v > mean(v));

        end

        psi = max(f);
    end   
%}

%{
    function [match,chi] = computeChi(row,col)
        
        % Find mean center off mas across fixations
        meanCenterOffMass = 0;
        changedCenterOfMass = false;
        
        for e=1:nrOfEyePositionsInTesting,
            
            responses = dataPrEyePosition(e, :,row,col);
            centerOfMass = dot(responses,targets) / sum(responses);
            
            % dont include fixation if there was NO response, i.e. sum() =
            % 0, i.e centerOfMass is NaN
            if ~isnan(centerOfMass)
                meanCenterOffMass = meanCenterOffMass + centerOfMass;
                changedCenterOfMass = true;
            end
        end
        
        meanCenterOffMass = meanCenterOffMass / nrOfEyePositionsInTesting;
        
        % return errors
        chi = (targets - meanCenterOffMass).^2;
        [C I] = min(chi);
        match = I;
        
        % If tehre are NaN entries, it means this is 
        % a non-responsive neuron for atleast one eye position,
        % and hence we mark it so it will not be par tof analysis
        if ~changedCenterOfMass,
            match = -1;
            chi = -1 * ones(1,length(targets));
        end
    end
%}

%{
    function theta = computeTheta(row,col)
        
        sigma = 2; % 2 worked well
        theta = 0;
        responses = dataPrEyePosition(:,:,row,col);
        
        counter = 0;
        
        for target_i=1:length(targets),
            for eye_j=1:length(eyePositions),
                
                notAllTargets = 1:length(targets);
                notAllTargets(target_i) = []; % Remove
                
                for target_k=notAllTargets,
                    for eye_l=1:length(eyePositions),
                        c = responses(eye_j,target_i)*responses(eye_l,target_k)*exp(-((targets(target_i)-eyePositions(eye_j)) - (targets(target_k) - eyePositions(eye_l)))^2/(2*sigma^2));
                        
                        
                        theta = theta + c;
                        
                        counter = counter + 1;
                    end
                end
            end
        end
        
        theta = theta/counter;
    end

%}
end
    
