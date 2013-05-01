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
    eyeCenteredNess = zeros(y_dimension, x_dimension);
    RFSize = zeros(y_dimension, x_dimension);
    RFSize_Confidence = zeros(y_dimension, x_dimension);
    RFLocation = zeros(y_dimension, x_dimension);
    RFLocation_Confidence = zeros(y_dimension, x_dimension);
    DiscardStatus = zeros(y_dimension, x_dimension);
    
    targets = info.targets;
    eyePositions = info.eyePositions;
    nrOfEyePositions = length(eyePositions);
    
    delta = abs(targets(2) - targets(1));
    targetShiftPerConsecutiveEyeShift = abs(eyePositions(2) - eyePositions(1))/delta;

    % Compute metrics
    wellBehavedNeurons = [];
    if networkDimensions(numRegions).isPresent,
        
        % Iterate cells
        for row = 1:y_dimension,
            for col = 1:x_dimension,
                
                % Head-centeredness
                headCenteredNess(row, col) = computeHeadCenteredNess(row,col);
                
                % Eye-centeredness
                eyeCenteredNess(row, col) = computeEyeCenteredNess(row,col);
                
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
                    v = [row col headCenteredNess(row, col) eyeCenteredNess(row, col) RFSize(row, col) RFSize_Confidence(row, col) RFLocation(row, col) RFLocation_Confidence(row,col)];
                    wellBehavedNeurons = [wellBehavedNeurons; v];
                end

            end
        end
    else
        error('Last layer is not present!');
    end
    
    Index = (headCenteredNess-eyeCenteredNess)./(headCenteredNess+eyeCenteredNess);
    
    %% Save data in .mat file
    
    % Well behaved
    analysisResults.wellBehavedNeurons      = wellBehavedNeurons;
    
    % Matrix form
    analysisResults.headCenteredNess        = headCenteredNess;
    analysisResults.eyeCenteredNess         = eyeCenteredNess;
    analysisResults.Index                   = Index;
    analysisResults.RFSize                  = RFSize;
    analysisResults.RFLocation              = RFLocation;
    analysisResults.RFSize_Confidence       = RFSize_Confidence;
    analysisResults.RFLocation_Confidence   = RFLocation_Confidence;
    analysisResults.DiscardStatus           = DiscardStatus;
    
    % Linearize
    analysisResults.headCenteredNess_Linear         = analysisResults.headCenteredNess(:);
    analysisResults.eyeCenteredNess_Linear          = analysisResults.eyeCenteredNess(:);
    analysisResults.Index_Linear                    = analysisResults.Index(:);
    analysisResults.RFSize_Linear                   = analysisResults.RFSize(:);
    analysisResults.RFLocation_Linear               = analysisResults.RFLocation(:);
    analysisResults.RFSize_Confidence_Linear        = analysisResults.RFSize_Confidence(:);
    analysisResults.RFLocation_Confidence_Linear    = analysisResults.RFLocation_Confidence(:);
    analysisResults.DiscardStatus_Linear            = analysisResults.DiscardStatus(:);
    
    % Discard
    d = analysisResults.DiscardStatus_Linear;
    
    analysisResults.headCenteredNess_Linear_Clean         = analysisResults.headCenteredNess_Linear(d > 0);
    analysisResults.eyeCenteredNess_Linear_Clean          = analysisResults.eyeCenteredNess_Linear(d > 0);
    analysisResults.Index_Linear_Clean                    = analysisResults.Index_Linear(d > 0);
    analysisResults.RFSize_Linear_Clean                   = analysisResults.RFSize_Linear(d > 0);
    analysisResults.RFLocation_Linear_Clean               = analysisResults.RFLocation_Linear(d > 0);
    analysisResults.RFSize_Confidence_Linear_Clean        = analysisResults.RFSize_Confidence_Linear(d > 0);
    analysisResults.RFLocation_Confidence_Linear_Clean    = analysisResults.RFLocation_Confidence_Linear(d > 0);
    analysisResults.DiscardStatus_Linear_Clean            = analysisResults.DiscardStatus_Linear(d > 0);
    
    % Summary Statistics
    analysisResults.fractionDiscarded               = nnz(DiscardStatus) / numNeurons;
    analysisResults.fractionDiscarded_Discontinous  = nnz(bitget(DiscardStatus,2)) / numNeurons;
    analysisResults.fractionDiscarded_Edge          = nnz(bitget(DiscardStatus,3)) / numNeurons;
    analysisResults.fractionDiscarded_MultiPeak     = nnz(bitget(DiscardStatus,4)) / numNeurons;
    analysisResults.fractionVeryHeadCentered        = nnz(analysisResults.Index_Linear_Clean >= 0) / numNeurons;
    
    %{
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
    %}
    
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
        
        %peakResponse = ratio*max(max(dataPrEyePosition(:,:,row,col)));

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

    function lambdaEye = computeEyeCenteredNess(row,col)

        corr = 0;
        combinations = 0;

        % Iterate all combinations of eye positions
        for ep_1 = 1:(nrOfEyePositionsInTesting - 1),
            for ep_2 = (ep_1+1):nrOfEyePositionsInTesting,
                
                % Align
                t1 = dataPrEyePosition(ep_1,:,row,col)';
                t2 = dataPrEyePosition(ep_2,:,row,col)';

                t1 = t1((1+targetShiftPerConsecutiveEyeShift*(nrOfEyePositions - 1 - (ep_1 - 1))):(end - targetShiftPerConsecutiveEyeShift*(ep_1-1)));
                t2 = t2((1+targetShiftPerConsecutiveEyeShift*(nrOfEyePositions - 1 - (ep_2 - 1))):(end - targetShiftPerConsecutiveEyeShift*(ep_2-1)));
                
                %Classic
                observationMatrix = [t1 t2];
                correlationMatrix = corrcoef(observationMatrix);
                c = correlationMatrix(1,2); % pick one of the two identical non-diagonal element :)
                
                corr = corr + c;
                combinations = combinations + 1;

            end
        end
        
        lambdaEye = corr / combinations;
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
        
            %{
            old shit:
            p = polyfit(usedEyePositions,centersOfMass,1);
            a = p(1);
            b = p(2);

            %3) Deduce best fitting x+h for ax+b
            h = b + (a+1)/numUsedEyePositions*sum(usedEyePositions);
            
            %4) Fitness
            
            % sum of square
            sse = sum((centersOfMass - (usedEyePositions + h)).^2);
            
            % total sum of square
            meanCenterOfMass = mean(centersOfMass);
            sst = sum((centersOfMass - meanCenterOfMass).^2);

            residue = sse/sst; % 1-sse/sst;
            %}
            
            h = mean(centersOfMass);
            residue = std(centersOfMass);
            
        else
            h = NaN;
            residue = NaN;
        end
        
    end

end
    
