%
%  metrics.m
%  SMI
%
%  Created by Bedeho Mender on 15/11/11.
%  Copyright 2011 OFTNAI. All rights reserved.
%

function [analysis] = metrics(filename, nrOfEyePositionsInTesting)

    % Get dimensions
    [networkDimensions, nrOfPresentLayers, historyDimensions] = getHistoryDimensions(filename);
    
    % Load data
    [data, objectsPrEyePosition] = regionDataPrEyePosition(filename, nrOfEyePositionsInTesting);
    
    % Setup vars
    numRegions = length(networkDimensions);
    analysis = zeros(4,y_dimension, x_dimension); % (data,row,col), data is either head centerdness
    % (1) = \lambda^a
    % (2) = \psi^a
    % (3) = \Omega^a
    % (4...[4+#targets]) = \chi
    
    targets = ?;
    tMax = ?;
    offset = targets(1);
    delta = targets(2) - targets(1);
    
    % Get data
    dataPrEyePosition = data{numRegions,1};
    y_dimension = networkDimensions(numRegions).y_dimension;
    x_dimension = networkDimensions(numRegions).x_dimension;

    % Compute metrics
    if networkDimensions(r).isPresent,
        
        % Iterate cells
        for row = 1:y_dimension,
            for col = 1:x_dimension,

                % Lambda = average correlation
                analysis(1,row, col) = computeLambda(row,col);
                
                % Psi = Confinedness
                analysis(2,row, col) = computePsi(row,col,tMax);
                
                % Omega = Lambda/Psi
                if analysis(2,row, col) == 0
                    analysis(3,row, col) = 0;
                else
                    analysis(3,row, col) = analysis(1,row, col)/analysis(2,row, col);
                end
                
                % t^a = Preference
                result(4,row, col) = computeChi(row,col);
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

                observationMatrix = [dataPrEyePosition(:, ep_1,row,col) dataPrEyePosition(:, ep_2,row,col)];

                %if isConstant(observationMatrix(:, 1)) || isConstant(observationMatrix(:, 2)),
                %    c = 0; % uncorrelated
                %else

                    % correlation
                    correlationMatrix = corrcoef(observationMatrix);
                    c = correlationMatrix(1,2); % pick one of the two identical non-diagonal element :)

                %end

                corr = corr + c;
                combinations = combinations + 1;

            end
        end
        
        lambda = corr / combinations;
    end
    
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
    
    function chi = computeChi(row,col)
        
        % Find mean center off mas across fixations
        meanCenterOffMass = 0;
        
        for e=1:nrOfEyePositionsInTesting,
            
            responses = dataPrEyePosition(:, e,row,col);
            centerOfMass = dot(responses,targets) / sum(responses);
            meanCenterOffMass = meanCenterOffMass + centerOfMass;
        end
        
        meanCenterOffMass = meanCenterOffMass / nrOfEyePositionsInTesting;
        
        % return errors
        chi = norm(targets - meanCenterOffMass);
    end

    %function [test] = isConstant(arr)
    %    
    %    test = isequal(arr(1) * ones(length(arr),1), arr);
    %end
end
    