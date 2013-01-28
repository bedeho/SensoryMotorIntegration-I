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

$$ COMMAND LINE TEST TO RUN!
~/Dphil/Projects/SensoryMotorIntegration-I/Source/DerivedData/SensoryMotorIntegration-I/Build/Products/Release/SensoryMotorIntegration-I test 

~/Dphil/Projects/SensoryMotorIntegration-I/Experiments/multitargettest/L\=0.05000_S\=0.80_sS\=00000004.50_sT\=0.40_gIC\=0.0500_eS\=0.0_/Parameters.txt 

~/Dphil/Projects/SensoryMotorIntegration-I/Experiments/multitargettest/L\=0.05000_S\=0.80_sS\=00000004.50_sT\=0.40_gIC\=0.0500_eS\=0.0_/BlankNetwork/BlankNetwork.txt

~/Dphil/Projects/SensoryMotorIntegration-I/Stimuli/multitargettest-visualfield=200.00-eyepositionfield=60.00-fixations=120.00-targets=1.00-fixduration=0.30-fixationsequence=15.00-seed=72.00-samplingrate=1000.00-multiTest/data.dat

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
% multi object
% NEWMultiTargetTestingAnalysis('multitargettesting-visualfield=200.00-eyepositionfield=60.00-fixations=120.00-targets=2.00-fixduration=0.30-fixationsequence=15.00-seed=72.00-samplingrate=1000.00-multiTest','/Network/Servers/mac0.cns.ox.ac.uk/Volumes/Data/Users/mender/Dphil/Projects/SensoryMotorIntegration-I/Experiments/multitargettest_baseline/L=0.05000_S=0.80_sS=00000004.50_sT=0.40_gIC=0.0500_eS=0.0_/TrainedNetwork/firingRate.dat','/Network/Servers/mac0.cns.ox.ac.uk/Volumes/Data/Users/mender/Dphil/Projects/SensoryMotorIntegration-I/Experiments/multitargettest/L=0.05000_S=0.80_sS=00000004.50_sT=0.40_gIC=0.0500_eS=0.0_/TrainedNetwork',4)
%
% one object
% NEWMultiTargetTestingAnalysis('peakedgain-visualfield=200.00-eyepositionfield=60.00-fixations=120.00-targets=1.00-fixduration=0.30-fixationsequence=15.00-seed=72.00-samplingrate=1000.00-stdTest','/Network/Servers/mac0.cns.ox.ac.uk/Volumes/Data/Users/mender/Dphil/Projects/SensoryMotorIntegration-I/Experiments/multitargettest_baseline/L=0.05000_S=0.80_sS=00000004.50_sT=0.40_gIC=0.0500_eS=0.0_/TrainedNetwork/firingRate.dat','/Network/Servers/mac0.cns.ox.ac.uk/Volumes/Data/Users/mender/Dphil/Projects/SensoryMotorIntegration-I/Experiments/multitargettest_baseline/L=0.05000_S=0.80_sS=00000004.50_sT=0.40_gIC=0.0500_eS=0.0_/TrainedNetwork',4)
% 
% one object
% NEWMultiTargetTestingAnalysis('denser-visualfield=200.00-eyepositionfield=60.00-fixations=280.00-targets=1.00-fixduration=0.30-fixationsequence=35.00-seed=72.00-samplingrate=1000.00-stdTest','/Network/Servers/mac0.cns.ox.ac.uk/Volumes/Data/Users/mender/Dphil/Projects/SensoryMotorIntegration-I/Experiments/denser/L=0.05000_S=0.90_sS=00000004.50_sT=0.02_gIC=0.0500_eS=0.0_/TrainedNetwork/firingRate.dat','/Network/Servers/mac0.cns.ox.ac.uk/Volumes/Data/Users/mender/Dphil/Projects/SensoryMotorIntegration-I/Experiments/denser/L=0.05000_S=0.90_sS=00000004.50_sT=0.02_gIC=0.0500_eS=0.0_/TrainedNetwork',4)

function NEWMultiTargetTestingAnalysis(stimuliName, experimentPath)

    % Import global variables
    declareGlobalVars();
    
    global base;
    
    % Load multi target test info
    x = load([base 'Stimuli/' stimuliName '/info.mat']);
    multiTestInfo = x.info;
    targets = multiTestInfo.targets;
    eyePositions = multiTestInfo.targets;
    
    numEyePositions = length(eyePositions);
    numTarget = length(targets);
    numberOfSimultanousTargetsDuringTesting = multiTestInfo.numberOfSimultanousTargetsDuringTesting;
    
    % Load firing response
    disp('Loading data...');
    [data, objectsPrEyePosition] = regionDataPrEyePosition([experimentPath '/firingRate.dat'], numEyePositions); % (object, eye_position, row, col, region)
    data = squeeze(data);
    d = size(data);
    numRows = d(end-1);
    numCols = d(end);
    total = numRows*numCols;
    
    %[baseline_data, baseline_objectsPrEyePosition] = regionDataPrEyePosition(baselineFiringRateFile, nrOfEyePositionsInTesting);
    %baseline_data = squeeze(baseline_data);
        
    disp('Processing...');
    doNeuron(27,5);
    
    %{
    % for each neuro
    for row=1:numRows,
        for col=1:numCols,
            
            % find lambda
            
            % find receptive field location
            
        end
    end
    %}
    
    
    function plotNeuron(row,col)
        
        if(numberOfSimultanousTargetsDuringTesting ~= 2),
            error('Cannot plot with ~=2 sim targets');
        end
        
        %Iterate eye position
        for e=eyePositions,
            
            x = permute(data(:,:,row,col),[2 1]); %tar
            k = reshape(x, [numTarget^2 numTarget]);
            surf(k);
        end

    end
    
 
    
    %{
    
    gg = linearNeurons; % [3 99 1 4 6 22]'
    %[I,J] = ind2sub([numRows numCols],gg)
    RF_Preference = analysisResults.RFLocation(gg); 
    [responses distances] = doPattern(1, 40, gg);
        
    % PLOT
    scatterPlotWithMarginalHistograms({distances}, {responses} ,'FaceColors', {[1,0,0]}, 'XTitle' , 'Error (deg)' , 'YTitle' , 'Firing Rate');
    %}
    
    %{
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
    %}
    
    %{
    function [response_ distance_] = doPattern(e, t, theseNeurons)
        
        nrCells = length(theseNeurons);
        
        %response_ = squeeze(data(e,t, theseNeurons));
        
        response_ = squeeze(data(e,t, :));
        
        [B,IX] = sort(response_, 'ascend');
        
        v = find(ismember(IX, theseNeurons)); % v is the position in IX where theseNeurns are found, which match the posionts in B where their firingr rates are.
        
        response_ = v/total; % normalize

        % distance metric
        targetCombinations = targets(allTargetCombinations(t,:));
        comparisonvector = repmat(targetCombinations, nrCells, 1);
        error = (comparisonvector - repmat(RF_Preference, 1, numberOfSimultanousTargetsDuringTesting));
        
        if numberOfSimultanousTargetsDuringTesting == 1,
            distance_ = error;
        else
            [C I] = min(abs(error)');
            linearIndexes = sub2ind([nrCells 2], (1:nrCells)',  I');
            distance_ = error(linearIndexes);
        end
        
        
        %% Find false negative neurons
        for n=1:length(theseNeurons),
            
            [I,J] = ind2sub([numRows numCols], theseNeurons(n));
            %{
            if abs(error(n)) < 0.1 && response_(n) < 0.01 % && abs(analysisResults.RFLocation(I,J) - 11) < 5,
                
                
                disp(['for e,t,n - (row,col):' num2str(e) ',' num2str(t) ',' num2str(n) ' - (' num2str(I) ',' num2str(J) ')' ]);
                
            end
            %}
            
           if abs(error(n)) > 30 && response_(n) > 0.8, % && abs(analysisResults.RFLocation(I,J) - 11) < 5,
                
                
                disp(['for e,t,n - (row,col):' num2str(e) ',' num2str(t) ',' num2str(n) ' - (' num2str(I) ',' num2str(J) ')' ]);
                
           end
            
        end
        
        
        %min((preferredHeadPosition-targetCombinations).^2);
        %sigma = 5;
        %exp(-min(((comparisonvector - repmat(receptivefields,1,numberOfSimultanousTargetsDuringTesting)).^2)')/(2*sigma^2));
        %leastTargetError = leastTargetError';

    end
    %}

    
end