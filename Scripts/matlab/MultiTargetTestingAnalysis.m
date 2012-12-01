%
%  MultiTargetTestingAnalysis.m
%  SMI
%
%  Created by Bedeho Mender on 19/11/12.
%  Copyright 2012 OFTNAI. All rights reserved.
%
%  Purpose: tests and produces plots for multiple target test
% 
%  Workflow for multi target testing:
%
%  1) Run classic experiment with testing and training on normal data
%
%  2) Create a new experiment folder manually, put the following files
%  from 1) into this folder
%        *TrainedNetwork.txt
%        *Parameters.txt
%        *analysisResults.mat
%
%  3) Generate stimuli by turning on OneD_Stimuli_MultiTargetTesting.m in
%  stimuli generator script.
%
%  4) Run simulator directly (not Run.pl) to run experiment with stimuli
%  from 3)
%{

~/Dphil/Projects/SensoryMotorIntegration-I/Source/DerivedData/SensoryMotorIntegration-I/Build/Products/Release/SensoryMotorIntegration-I test 

~/Dphil/Projects/SensoryMotorIntegration-I/Experiments/multitargettest/L\=0.05000_S\=0.80_sS\=00000004.50_sT\=0.40_gIC\=0.0500_eS\=0.0_/Parameters.txt 

~/Dphil/Projects/SensoryMotorIntegration-I/Experiments/multitargettest/L\=0.05000_S\=0.80_sS\=00000004.50_sT\=0.40_gIC\=0.0500_eS\=0.0_/BlankNetwork/BlankNetwork.txt

~/Dphil/Projects/SensoryMotorIntegration-I/Stimuli/multitargettesting-visualfield=200.00-eyepositionfield=60.00-fixations=120.00-targets=2.00-fixduration=0.30-fixationsequence=15.00-seed=72.00-samplingrate=1000.00-multiTest/data.dat

~/Dphil/Projects/SensoryMotorIntegration-I/Experiments/multitargettest/L\=0.05000_S\=0.80_sS\=00000004.50_sT\=0.40_gIC\=0.0500_eS\=0.0_/TrainedNetwork/TrainedNetwork.txt 

COPY-PASTE:
~/Dphil/Projects/SensoryMotorIntegration-I/Source/DerivedData/SensoryMotorIntegration-I/Build/Products/Release/SensoryMotorIntegration-I test ~/Dphil/Projects/SensoryMotorIntegration-I/Experiments/multitargettest/L\=0.05000_S\=0.80_sS\=00000004.50_sT\=0.40_gIC\=0.0500_eS\=0.0_/Parameters.txt ~/Dphil/Projects/SensoryMotorIntegration-I/Experiments/multitargettest/L\=0.05000_S\=0.80_sS\=00000004.50_sT\=0.40_gIC\=0.0500_eS\=0.0_/TrainedNetwork/TrainedNetwork.txt ~/Dphil/Projects/SensoryMotorIntegration-I/Stimuli/multitargettesting-visualfield=200.00-eyepositionfield=60.00-fixations=120.00-targets=2.00-fixduration=0.30-fixationsequence=15.00-seed=72.00-samplingrate=1000.00-multiTest/data.dat ~/Dphil/Projects/SensoryMotorIntegration-I/Experiments/multitargettest/L\=0.05000_S\=0.80_sS\=00000004.50_sT\=0.40_gIC\=0.0500_eS\=0.0_/TrainedNetwork/ 

%}
%  5) Run this script where
%  stimuliName = name of test/train/multitest stimuli is used
%  experimentPath = path to manually created folder in 2)
%  nrOfEyePositionsInTesting = same as before
%
% e.g.: OneD_Stimuli_Training('multitargettraining')
%
% MultiTargetTestingAnalysis('multitargettesting-visualfield=200.00-eyepositionfield=60.00-fixations=120.00-targets=2.00-fixduration=0.30-fixationsequence=15.00-seed=72.00-samplingrate=1000.00','/Network/Servers/mac0.cns.ox.ac.uk/Volumes/Data/Users/mender/Dphil/Projects/SensoryMotorIntegration-I/Experiments/multitargettest_baseline/L=0.05000_S=0.80_sS=00000004.50_sT=0.40_gIC=0.0500_eS=0.0_/TrainedNetwork/firingRate.dat','/Network/Servers/mac0.cns.ox.ac.uk/Volumes/Data/Users/mender/Dphil/Projects/SensoryMotorIntegration-I/Experiments/multitargettest/L=0.05000_S=0.80_sS=00000004.50_sT=0.40_gIC=0.0500_eS=0.0_/TrainedNetwork',4)

function MultiTargetTestingAnalysis(stimuliName, baselineFiringRateFile, experimentPath, nrOfEyePositionsInTesting)

    % Import global variables
    declareGlobalVars();
    
    global base;

    % Read out analysis results
    x = load([experimentPath '/analysisResults.mat']);
    analysisResults = x.analysisResults;
    
    % Load multi target test info
    x = load([base 'Stimuli/' stimuliName '-multiTest/info.mat']);
    multiTestInfo = x.info;
    
    targets = multiTestInfo.targets;
    allTargetCombinations = multiTestInfo.allTargetCombinations;
    numCombinations = length(allTargetCombinations);
    numberOfSimultanousTargetsDuringTesting = multiTestInfo.numberOfSimultanousTargetsDuringTesting;
    
    
    % Load firing response
    disp('Loading data...');
    [data, objectsPrEyePosition] = regionDataPrEyePosition([experimentPath '/firingRate.dat'], nrOfEyePositionsInTesting); % (object, eye_position, row, col, region)
    
    [baseline_data, baseline_objectsPrEyePosition] = regionDataPrEyePosition(baselineFiringRateFile, nrOfEyePositionsInTesting);
    
    disp('Processing...');
    
    % clean out.
    data = squeeze(data);
    baseline_data = squeeze(baseline_data);
    
    d = size(data);
    
    numRows = d(end-1);
    numCols = d(end);
    
    
    %% Normalization step
    for r=1:numRows,
        for c=1:numCols,
            
            %totalmax = max(max(baseline_data(:,:,r,c)));
            %totalmax = max(max(data(:,:,r,c)));
            %data(:,:,r,c) = data(:,:,r,c)/totalmax;

            %totalmax = max(max(data(2,:,r,c)));
            %data(2,:,r,c) = data(2,:,r,c)/totalmax;
            
            
        end
    end

    
    
        include = analysisResults.wellBehavedNeurons(:,3) > 0.7;
        
        numCells = nnz(include);
        
        neurons = analysisResults.wellBehavedNeurons(include, [1 2]);
        
        linearNeurons = sub2ind([numRows numCols], neurons(:,1), neurons(:,2));
        
        RF_Preference = analysisResults.wellBehavedNeurons(include, 6); 
        
    %{
        [r d] = doPattern(1, 7);
        
        for a =1:length(r),
            
            if r(a) < 0.1 && abs(d(a)) < 5
                
                disp(['Response: ' num2str(r(a))]);
                disp(['Distance: ' num2str(d(a))]);
                
                allincluded = find(include);
                
                analysisResults.wellBehavedNeurons(allincluded(a), :)
                disp('found it');
            end
            
        end
        %}
        
    %doPattern(2,14);
    
    r = [];
    d = [];
    
    for e=1:nrOfEyePositionsInTesting,

        for t = 1:numCombinations,

            [response distance] = doPattern(e, t);
            r = [r response'];
            d = [d distance'];
            
        end
    end
    
    
    scatterPlotWithMarginalHistograms({(d)}, {r} ,'FaceColors', {[1,0,0]}, 'XTitle' , 'Error (deg)' , 'YTitle' , 'Firing Rate');
    
    % do probability plot
    %maxDistance = max(abs(d));
    
    %distances = 1:10:maxDistance;
    %distribution = zeros(1, length(distances) - 1); % F(r') = std of of error distribution for all points with r = r'
    
    range = 0:0.1:1;
    standardDeviations = zeros(1, length(range) - 1);
    means = zeros(1, length(range) - 1);
    
    for i=1:length(standardDeviations),
        
        dvalues = d(((range(i) <= r) & (r < range(i+1)))); % pick out right responses
        standardDeviations(i) = std(dvalues);
        means(i) = mean(dvalues);
        
    end
    
    % Plot
    figure;
    X = range(1:(end-1));
    [AX,H1,H2] = plotyy(X, standardDeviations, X, means);  % ,'semilogx'
    
    % Appearance
    hXLabel = xlabel('Firing Rate');
    
    hYLabel1 = get(AX(1),'Ylabel');
    hYLabel2 = get(AX(2),'Ylabel');
    
    set(hYLabel1,'String', 'Conditional Standard Deviation (deg)');
    set(hYLabel2,'String', 'Conditional Mean (deg)');

    set(H1,'LineStyle','-','Marker','o','LineWidth',2);
    set(H2,'LineStyle','--','Marker','o','LineWidth',2);
    
    %set([AX hXLabel hYLabel1 hYLabel2], 'FontSize', 14);
    
    set(gca,'XGrid','on');

    
    %if(exist('XTick')),
    %    set(AX,'XTick', XTick);
    %end
    
    
    
    function [response distance] = doPattern(e, t)
        

        response = squeeze(data(e,t,linearNeurons));

        % distance metric
        
        targetCombinations = targets(allTargetCombinations(t,:))
        comparisonvector = repmat(targetCombinations, numCells, 1);
        
        error = (comparisonvector - repmat(RF_Preference, 1, numberOfSimultanousTargetsDuringTesting));
        
        [C I] = min(abs(error)');
        
        linearIndexes = sub2ind([numCells 2], (1:numCells)',  I');
        
        distance = error(linearIndexes);
        
        
        
        
        %min((preferredHeadPosition-targetCombinations).^2);
        
        %sigma = 5;
        %exp(-min(((comparisonvector - repmat(receptivefields,1,numberOfSimultanousTargetsDuringTesting)).^2)')/(2*sigma^2));
        %leastTargetError = leastTargetError';

    end
    
    
    %{
doNeuron(27,5)
    
    function corr = doNeuron(row,col)
        
        leastTargetErrors = zeros(1, numCombinations);
        responses = zeros(1, numCombinations);
       
        preferredHeadPosition = analysisResults.RFLocation(row,col);
        
        sigma = 5;
        
        figure;
        imagesc(data(:,:,row,col));
        colorbar
        
        figure;
        for e=1:nrOfEyePositionsInTesting,
            
            for t = 1:numCombinations,

                targetCombinations = targets(allTargetCombinations(t,:));

                leastTargetError(t) = exp(-min((preferredHeadPosition-targetCombinations).^2)/(2*sigma^2)); %min((preferredHeadPosition-targetCombinations).^2);

                response = data(e, t, row, col);

                plot(response, leastTargetError(t), 'o');
                hold on
            end
        end
        
        xlim([0 1]);
        
        
        %plot(leastTargetErrors, responses);
        
        %
        %coeff(leastTargetErrors,responses);
        
    end
    %}
    
    

end