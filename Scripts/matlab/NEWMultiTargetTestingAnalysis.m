%
%  NEWMultiTargetTestingAnalysis.m
%  SMI
%
%  Created by Bedeho Mender on 19/11/12.
%  Copyright 2012 OFTNAI. All rights reserved.
%
%  Purpose: tests and produces plots for multiple target test
% 
%  Workflow for multi target testing:
%
%  1) Generate classic and multi test stimuli
%
%  2) Run classic experiment with testing and training on normal stimuli
%
%  3) Create a new experiment folder "multitargettest" manually, put
%  "TrainedNetwork.txt" and "Parameters.txt" in the folder
%
%  4) Run simulator directly (not Run.pl) to run experiment with multitarget testing
%  stimuli from 1)
%
%  5) Run *this* script where
%  stimuliName = name of multitest stimuli
%  experimentPath = path to manually created folder in 2)

%~/Dphil/Projects/SensoryMotorIntegration-I/Source/DerivedData/SensoryMotorIntegration-I/Build/Products/Release/SensoryMotorIntegration-I test ~/Dphil/Projects/SensoryMotorIntegration-I/Experiments/multitargettest/Parameters.txt ~/Dphil/Projects/SensoryMotorIntegration-I/Experiments/multitargettest/TrainedNetwork.txt ~/Dphil/Projects/SensoryMotorIntegration-I/Stimuli/multitargettest-visualfield=200.00-eyepositionfield=60.00-fixations=120.00-targets=1.00-fixduration=0.30-fixationsequence=15.00-seed=72.00-samplingrate=100.00-multiTest/data.dat ~/Dphil/Projects/SensoryMotorIntegration-I/Experiments/multitargettest/


function NEWMultiTargetTestingAnalysis(stimuliName, experimentPath)

    % Import global variables
    declareGlobalVars();
    
    global base;
    
    % Load multi target test info
    x = load([base 'Stimuli/' stimuliName '/info.mat']);
    multiTestInfo = x.info;
    targets = multiTestInfo.targets;
    eyePositions = multiTestInfo.eyePositions;
    
    numEyePositions = length(eyePositions);
    numTarget = length(targets);
    numberOfSimultanousTargetsDuringTesting = 2;
    
    delta = abs(targets(2) - targets(1));
    
    %% Load Data
    % Load firing response
    disp('Loading data...');
    
    %[data, objectsPrEyePosition] = regionDataPrEyePosition([experimentPath '/firingRate.dat'], numEyePositions); % (object, eye_position, row, col, region)

    % MT_untrained
    %q = load('MT_untrained.mat');
    %data = q.data;
    
    % MT_singeltargettrained
    q = load('MT_singeltargettrained.mat');
    data = q.data;
    
    data = squeeze(data);
    d = size(data);
    numRows = d(end-1);
    numCols = d(end);
    total = numRows*numCols;
    
    %[baseline_data, baseline_objectsPrEyePosition] = regionDataPrEyePosition(baselineFiringRateFile, nrOfEyePositionsInTesting);
    %baseline_data = squeeze(baseline_data);

    %% Processing
    disp('Processing...');
    headCenteredness = zeros(numRows,numCols);
    receptivefieldlocations = zeros(numRows,numCols);
    receptivefieldsizes = zeros(numRows,numCols);
   
    
    % for each neuro
    for row=1:numRows,
        for col=1:numCols,
            
            %data(:,:,row,col)
            
            headCenteredness(row,col) = computeLambda(row,col);
            receptivefieldlocations(row,col) = computeRFLocation(row,col);
            receptivefieldsizes(row,col) = computeRFSize(row,col);
            
        end
    end
    
    %% Overview
    
    figure;
    imagesc(headCenteredness);
    title('headCenteredness');
    colorbar;
    
    figure;
    imagesc(receptivefieldlocations);
    title('computeRFLocation');
    colorbar;
        
    figure;
    imagesc(receptivefieldsizes);
    title('computeRFSize');
    colorbar;
    
    
    %% Invidivudal neurons
    plotNeuron(19,15)
    
    %% Population plots
    %FaceColors = {[1,0,0]};
    %scatterPlotWithMarginalHistograms({receptivefieldlocations(:)}, {headCenteredness(:)}, 'XTitle', 'Receptive Field Location (deg)', 'YTitle', 'Head-Centeredness', 'Legends', 'X','YLabelOffset', 3, 'FaceColors', FaceColors);
    
    function plotNeuron(row,col)
       
        disp(['Lambda = ' num2str(computeLambda(row,col))]);
        disp(['h-value = ' num2str(computeRFLocation(row,col))]);
        disp(['psi = ' num2str(computeRFSize(row,col))]);
        
        if(numberOfSimultanousTargetsDuringTesting ~= 2),
            error('Cannot plot with ~=2 sim targets');
        end
        
        figure;
        
        %Iterate eye position
        for e=1:numEyePositions,

            k = reshape(data(e,:,row,col), [numTarget numTarget]); % frontground target,backgrond target
            subplot(1,numEyePositions,e);; 
            contourf(k); % imagesc
            colorbar
            
        end

    end

    function lambda = computeLambda(row,col)
        
        x = squeeze(data(:,:,row,col))';
        k = reshape(x, [numTarget (numTarget*numEyePositions)]);
        
        %comput correlation
        corr = corrcoef(k);
        
        % identifty nans
        nans = isnan(corr);
        
        %save them
        numberOfNan = nnz(nans);
        
        %remove from total
        corr(nans) = 0;
        
        % number of response functions
        numObservations = (numTarget*numEyePositions);
        
        % Avrage all nonzero values.
        lambda = (sum(sum(corr)) -  numObservations)/(numel(corr)-numberOfNan);
        
    end
        
    function [h residue] = computeRFLocation(row,col)
        
        %1) Find all centers of mass
        centersOfMass = zeros(1,numEyePositions);
        
        %Iterate eye position
        for e=1:numEyePositions,
            
            responseCurve = reshape(squeeze(data(e,:,row,col)), numTarget, numTarget); % frontground target,backgrond target
            
            responseSums = (sum(responseCurve))';
            
            % compute centroids
            masses = (responseCurve'*targets')./responseSums; %% < are targets in the right order??
            
            % remove nans
            masses(isnan(masses)) = [];
            
            % average them
            centersOfMass(e) = mean(masses);
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
   
    function [psi rfSTDEV maxNumIntervals] = computeRFSize(row,col)
        
        raw = data(:,:,row,col);
        AllResponses = reshape(raw, [numTarget (numTarget*numEyePositions)])';
        numResponses = length(AllResponses);
        
        maxNumIntervals = 0;
        receptiveFieldSizes = zeros(1,numResponses);
        peakResponse = 0.5*max(max(raw));
        
        % Iterate responses
        for a=1:numResponses,
            
            intervals = findIntervals(AllResponses(a,:), 0, delta, peakResponse); % (interval bounds [a,b],interval)
            
            subReceptiveFieldSizes = diff(intervals);
            
            receptiveFieldSizes(a) = sum(subReceptiveFieldSizes);
            
            [rubish numIntervals] = size(intervals);
            maxNumIntervals = max(maxNumIntervals, numIntervals);
            
        end

        psi = mean(receptiveFieldSizes);
        rfSTDEV = std(receptiveFieldSizes);
        
    end
  
end