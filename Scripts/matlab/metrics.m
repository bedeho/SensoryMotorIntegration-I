%
%  metrics.m
%  SMI
%
%  Created by Bedeho Mender on 15/11/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%

function analysisResults = metrics(filename, info)

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
    numNeurons = x_dimension*y_dimension;

    headCenteredNess = zeros(y_dimension, x_dimension);
    RFSize = zeros(y_dimension, x_dimension);
    RFSize_Confidence = zeros(y_dimension, x_dimension);
    RFLocation = zeros(y_dimension, x_dimension);
    RFLocation_Confidence = zeros(y_dimension, x_dimension);
    DiscardStatus = zeros(y_dimension, x_dimension);
    
    targets = info.targets;
    eyePositions = info.eyePositions;
    
    %offset = targets(1);
    delta = abs(targets(2) - targets(1));

    % Compute metrics
    wellBehavedNeurons = [];
    if networkDimensions(numRegions).isPresent,
        
        % Iterate cells
        for row = 1:y_dimension,
            for col = 1:x_dimension,
                
                % Head-centeredness
                headCenteredNess(row, col) = computeHeadCenteredNess(row,col);
                
                % Receptive Field Size
                [psi rfSTDEV maxNumIntervals] = computeRFSize(row,col);
                RFSize(row, col) = psi;
                RFSize_Confidence(row, col) = rfSTDEV;
                 
                % Receptive Field Location
                [h residue] = computeRFLocation(row,col);
                RFLocation(row, col) = h;
                RFLocation_Confidence(row, col) = residue;
                
                % Discard Status
                DiscardStatus(row,col) = discardStatus(row,col,maxNumIntervals);
                
                if(DiscardStatus(row,col) == 0),
                    v = [row col headCenteredNess(row, col) RFSize(row, col) RFSize_Confidence(row, col) RFLocation(row, col) RFLocation_Confidence(row,col)];
                    wellBehavedNeurons = [wellBehavedNeurons; v];
                end

            end
        end
    else
        error('Last layer is not present!');
    end
    
    % Data
    headCenteredNess_Linear             = headCenteredNess(:);
    RFSize_Linear                       = RFSize(:);
    RFSize_Confidence_Linear            = RFSize_Confidence(:);
    RFLocation_Linear                   = RFLocation(:);
    RFLocation_Confidence_Linear        = RFLocation_Confidence(:);
    DiscardStatus_Linear                = DiscardStatus(:);
    
    % Discard neurons
    headCenteredNess_Linear_Clean       = headCenteredNess_Linear;
    RFSize_Linear_Clean                 = RFSize_Linear;
    RFLocation_Linear_Clean             = RFLocation_Linear;
    
    RFSize_Confidence_Linear_Clean      = RFSize_Confidence_Linear;
    RFLocation_Confidence_Linear_Clean  = RFLocation_Confidence_Linear;
    
    headCenteredNess_Linear_Clean(DiscardStatus_Linear > 0)         = [];
    RFSize_Linear_Clean(DiscardStatus_Linear > 0)                   = [];
    RFLocation_Linear_Clean(DiscardStatus_Linear > 0)               = [];
    RFSize_Confidence_Linear_Clean(DiscardStatus_Linear > 0)        = [];
    RFLocation_Confidence_Linear_Clean(DiscardStatus_Linear > 0)    = [];
    
    % analysis results
    analysisResults.headCenteredNess = headCenteredNess;
    analysisResults.RFSize = RFSize;
    analysisResults.RFLocation = RFLocation;
    analysisResults.RFSize_Confidence = RFSize_Confidence;
    analysisResults.RFLocation_Confidence = RFLocation_Confidence;
    
    analysisResults.headCenteredNess_Linear = headCenteredNess_Linear;
    analysisResults.RFSize_Linear = RFSize_Linear;
    analysisResults.RFLocation_Linear = RFLocation_Linear;
    analysisResults.DiscardStatus_Linear = DiscardStatus_Linear;
    
    analysisResults.headCenteredNess_Linear_Clean = headCenteredNess_Linear_Clean;
    analysisResults.RFSize_Linear_Clean = RFSize_Linear_Clean;
    analysisResults.RFLocation_Linear_Clean = RFLocation_Linear_Clean;
    analysisResults.RFSize_Confidence_Linear_Clean = RFSize_Confidence_Linear_Clean;
    analysisResults.RFLocation_Confidence_Linear_Clean = RFLocation_Confidence_Linear_Clean;
    
    analysisResults.DiscardStatus = DiscardStatus;
    analysisResults.wellBehavedNeurons = wellBehavedNeurons;
    
    % Discarding cases
    analysisResults.fractionDiscarded               = nnz(DiscardStatus) / numNeurons;
    analysisResults.fractionDiscarded_Discontinous  = nnz(bitget(DiscardStatus,2)) / numNeurons;
    analysisResults.fractionDiscarded_Edge          = nnz(bitget(DiscardStatus,3)) / numNeurons;
    analysisResults.fractionDiscarded_MultiPeak     = nnz(bitget(DiscardStatus,4)) / numNeurons;
    
    % Very head-centered
    lambdaCutoff = 0.7;
    analysisResults.fractionVeryHeadCentered     = nnz(headCenteredNess_Linear_Clean >= lambdaCutoff) / numNeurons;
    
    % Uniformity
    vals = RFLocation_Linear_Clean(headCenteredNess_Linear_Clean >= lambdaCutoff);
    numEntropyBins = 40;
    dist = hist(vals,numEntropyBins)./ numel(vals);
    entropy = -dot(dist,log(dist)/log(2)); % -(dist*.log(dist)/log(2));
    maxEntropy = log(numEntropyBins)/log(2);
    
    analysisResults.entropy = entropy;
    analysisResults.maxEntropy = maxEntropy;
    analysisResults.uniformityOfVeryHeadCentered = entropy/maxEntropy;
    
    
    function discard = discardStatus(row,col,num)
        
        peakResponse = ratio*max(max(dataPrEyePosition(:,:,row,col)));
        response = dataPrEyePosition(:,:,row,col)';
        discard = 0;

        % Non-responsive rf: there is an eye position for which it is non-respnse ($r_i =0$) to all retinal locations
        if any(sum(response > 0) == 0),
            discard = discard + 2;
        end
        
        %{
        % Edge bias: there is an eye position for which the firing rate ($r_i$) is above the cut off in at least one of the two most eccentric retinal locations
        %{
        if any(response(1,:) > peakResponse) || any(response(end,:) > peakResponse),
            discard = discard + 4;
        end
        %}
        
        % Multi peaked:
        if num > 1,
            discard = discard + 8;
        end
        %}
        
    end
    
    function lambda = computeHeadCenteredNess(row,col)
        
        corr = 0;
        combinations = 0;
        
        peakResponse = ratio*max(max(dataPrEyePosition(:,:,row,col)));

        % Iterate all combinations of eye positions
        for ep_1 = 1:(nrOfEyePositionsInTesting - 1),
            for ep_2 = (ep_1+1):nrOfEyePositionsInTesting,

                %
                %Classic
                observationMatrix = [dataPrEyePosition(ep_1,:,row,col)' dataPrEyePosition(ep_2,:,row,col)'];
                correlationMatrix = corrcoef(observationMatrix);
                c = correlationMatrix(1,2); % pick one of the two identical non-diagonal element :)
                
                
                %c = dot(dataPrEyePosition(ep_1,:,row,col) - peakResponse,dataPrEyePosition(ep_2,:,row,col) - peakResponse)/(objectsPrEyePosition*(peakResponse*(1-ratio))^2);
                
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
            
            [rubish numIntervals] = size(intervals);
            maxNumIntervals = max(maxNumIntervals, numIntervals);
            
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
        numUsedEyePositions = length(usedEyePositions);
        
        %2) Do regression to find best fitting: ax+b
        
        if(length(usedEyePositions) > 1)
        
            p = polyfit(usedEyePositions,centersOfMass,1);
            a = p(1);
            b = p(2);

            %3) Deduce best fitting x+h for ax+b
            h = b - (1-a)/numUsedEyePositions*sum(usedEyePositions);
            
            %4) Fitness
            
            % sum of square
            sse = sum((centersOfMass - (usedEyePositions + h)).^2);
            
            % total sum of square
            meanCenterOfMass = mean(centersOfMass);
            sst = sum((centersOfMass - meanCenterOfMass).^2);

            residue = sse/sst; % 1-sse/sst;
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
    
