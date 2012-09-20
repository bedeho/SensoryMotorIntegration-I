%
%  metrics.m
%  SMI
%
%  Created by Bedeho Mender on 15/11/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%

function [analysis, thetaMatrix] = metrics(filename, info)

    % Get dimensions
    [networkDimensions, nrOfPresentLayers, historyDimensions] = getHistoryDimensions(filename);
    
    % Load data
    nrOfEyePositionsInTesting = length(info.eyePositions);
    [data, objectsPrEyePosition] = regionDataPrEyePosition(filename, nrOfEyePositionsInTesting);
    
    % Setup vars
    numRegions = length(networkDimensions);
    
    dataPrEyePosition = data{numRegions-1,1};
        
    y_dimension = networkDimensions(numRegions).y_dimension;
    x_dimension = networkDimensions(numRegions).x_dimension;
    analysis = zeros(4 + objectsPrEyePosition,y_dimension, x_dimension); % (data,row,col), data is either head centerdness
    
    thetaMatrix = zeros(y_dimension, x_dimension);
    % length(targets) == objectsPrEyePosition
    
    % (1) = \lambda^a
    % (2) = \psi^a
    % (3) = \Omega^a
    % (4) = best match target
    % (5...[5+#targets]) = \chi
    
    targets = info.targets;
    eyePositions = info.eyePositions;
    numTargets = length(targets);
    
    %offset = targets(1);
    %delta = targets(2) - targets(1);
    %tMax = delta; % can be smaller!

    % Compute metrics
    if networkDimensions(numRegions).isPresent,
        
        % Iterate cells
        for row = 1:y_dimension,
            for col = 1:x_dimension,

                % Lambda = average correlation
                analysis(1,row, col) = computeLambda(row,col);
                
                % Psi = Confinedness
                analysis(2,row, col) = computePsi(row,col);

                % Omega = Lambda/Psi
                if analysis(2,row, col) == 0
                    analysis(3,row, col) = 0;
                else
                    analysis(3,row, col) = analysis(1,row, col)/analysis(2,row, col);
                end
                
                [match,chi] = computeChi(row,col);
                
                % best match
                analysis(4,row, col) = match;
                
                % t^a = Preference
                analysis(5:end,row, col) = chi;
                
                % theta matrix
                thetaMatrix(row, col) = computeTheta(row,col);
            end
        end
    else
        error('Last layer is not present!');
    end
    
    function lambda = computeLambda(row,col)
        
        corr = 0;
        combinations = 0;

        % Iterate all combinations of eye positions
        for ep_1 = 1:(nrOfEyePositionsInTesting - 1),
            for ep_2 = (ep_1+1):nrOfEyePositionsInTesting,

                observationMatrix = [dataPrEyePosition(ep_1,:,row,col)' dataPrEyePosition(ep_2,:,row,col)'];

                %if isConstant(observationMatrix(:, 1)) || isConstant(observationMatrix(:, 2)),
                %    c = 0; % uncorrelated
                %else

                    % correlation
                    correlationMatrix = corrcoef(observationMatrix);
                    c = correlationMatrix(1,2); % pick one of the two identical non-diagonal element :)

                %end
                
                % c=NaN if neither neuron responds to anything
                if isnan(c)
                    c = 0;
                end

                corr = corr + c;
                combinations = combinations + 1;

            end
        end
        
        lambda = corr / combinations;
    end

    function psi = computePsi(row,col)

        f = zeros(1,nrOfEyePositionsInTesting);

        % Iterate all combinations of eye positions
        for k = 1:nrOfEyePositionsInTesting,

            v = dataPrEyePosition(k,:,row,col);
            f(k) = nnz(v > mean(v));

        end

        psi = max(f);
    end   

%{
    function psi = computePsi(row,col,tMax)
        
        confinedness = 0;

        % Iterate all combinations of eye positions
        for k = 1:nrOfEyePositionsInTesting,
            
            intervals = findIntervals(dataPrEyePosition(:, k,row,col), offset, delta); % (interval bounds [a,b],interval)
            
            headCenteredMass = 0;
            [tmp, numberOfIntervals] = size(intervals); % tmp = 2, but ~ notation is not backwards compatible
            
            for i=1:numberOfIntervals,
                headCenteredMass = headCenteredMass + ceil((intervals(2,i) - intervals(1,i))/tMax);
            end
            
            % Include if there where intervals,
            % notice that confinedness is still averaged
            % over all fixation points, regardless of whether
            % some of are not included, i.e. fail this test
            if numberOfIntervals > 0,
                confinedness = confinedness + headCenteredMass / numberOfIntervals;
            end
        end
        
        psi = confinedness / nrOfEyePositionsInTesting;
    end   
    %}

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
end
    
