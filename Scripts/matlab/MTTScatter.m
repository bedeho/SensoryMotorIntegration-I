%
%  MTTScatter.m
%  SMI
%
%  Created by Bedeho Mender on 19/11/12.
%  Copyright 2012 OFTNAI. All rights reserved.
%
%  Purpose: tests and produces plots for multiple target test, make sure
%  analysisResults.mat is in folder
%


%MTTScatter('dist_2_mulitargettest_2-visualfield=200.00-eyepositionfield=60.00-fixations=240.00-targets=1.00-fixduration=0.30-fixationsequence=30.00-seed=72.00-samplingrate=100.00-multiTest','/Network/Servers/mac0.cns.ox.ac.uk/Volumes/Data/Users/mender/Dphil/Projects/SensoryMotorIntegration-I/Experiments/MTT_global')

function MTTScatter(stimuliName, experimentPath)

    % Import global variables
    declareGlobalVars();
    
    global base;

    % Read out analysis results
    x = load([experimentPath '/analysisResults.mat']);
    analysisResults = x.analysisResults;
    
    % Load multi target test info
    x = load([base 'Stimuli/' stimuliName '/info.mat']);
    multiTestInfo = x.info;
    targets = multiTestInfo.targets;
    eyePositions = multiTestInfo.eyePositions;
    numTargets = length(targets);
    nrOfEyePositionsInTesting = length(multiTestInfo.eyePositions);
    numberOfSimultanousTargetsDuringTesting = 2;
    
    allTargetCombinations = [];
    for t1=1:numTargets,
        for t2=1:numTargets,
            allTargetCombinations = [allTargetCombinations; t1 t2];
        end
    end

    numCombinations = numTargets*numTargets;

    % Load Data
    data = regionDataPrEyePositionFASTLOADER(experimentPath);
    
    disp('Processing...');
    
    % Get Dimensions
    d = size(data);
    numRows = d(end-1);
    numCols = d(end);

    % Get 0.7< neurons
    neurons = analysisResults.wellBehavedNeurons(analysisResults.wellBehavedNeurons(:,3) > 0.7, [1 2]);
    linearNeurons = sub2ind([numRows numCols], neurons(:,1), neurons(:,2));
    analyze = linearNeurons;
    RF_Preference = analysisResults.RFLocation(analyze); 
    
    %% single neuron
    %{
    analyze = 121;
    RF_Preference = analysisResults.RFLocation(analyze);
    responses = [];
    distances = [];
    for e1=1:nrOfEyePositionsInTesting,

        [r d] = doPatternPerEyePosition(e1, analyze);

        scatterPlotWithMarginalHistograms({d}, {r} ,'FaceColors', {[1,0,0]}, 'XTitle' , 'Error (deg)' , 'YTitle' , 'Firing Rate');
        
        
    end
    %}
    
    %% Iterate all neurons
    %{
    r = []
    d = []
    for n=1:length(linearNeurons),
        
        RF_Preference = analysisResults.RFLocation(linearNeurons(n));
        
        for e1=1:nrOfEyePositionsInTesting,

            [r2 d2] = doPatternPerEyePosition(e1, linearNeurons(n));

            r = [r r2];
            d = [d d2];
        end
    
            
        %[r d] = doPatternPerEyePosition(2, linearNeurons(n));
        
        %if(abs(RF_Preference - (-10)) < 5), 
            scatterPlotWithMarginalHistograms({d}, {r} , 'FaceColors', {[1,0,0]}, 'XTitle', 'Error (deg)', 'YTitle', 'Firing Rate');
            title(num2str(RF_Preference));
        %end
        
        x=1;
        
    end
    %}
   
    %% How many neurons fail
    %{
    rfbin_edges = 0:0.1:1;
    rfbins = zeros(1,length(rfbin_edges)-1);
    linearNeurons = 91;
    
    for n=1:length(linearNeurons),
        
        n
        
        RF_Preference = analysisResults.RFLocation(linearNeurons(n));
        
        
        r = [];
        d = [];
        
        for e1=2,%nrOfEyePositionsInTesting,

            % Get response
            [r2 d2] = doPatternPerEyePosition(e1, linearNeurons(n));
            
            r = [r r2];
            d = [d d2];

        end
        
        % get rf size
        RFSize_Half = analysisResults.RFSize(linearNeurons(n))/2;
        
        % pick out the right ones
        frates = r(d <= RFSize_Half);

        % histogramize
        fhist = hist(frates, rfbin_edges);

        % drop last catchall bin
        fhist = fhist(1:(end-1));

        % binarize, we only want to count yes/no
        fhist(fhist > 0) = 1;

        % Add to rfbins
        rfbins = rfbins + fhist;

    end
    
    figure;
    bar(rfbins);
    %}
    
    %% Not consistently the same eye position
    %{
    distanceCell = cell(1,nrOfEyePositionsInTesting);
    responseCell = cell(1,nrOfEyePositionsInTesting);
    
    for n=1:100, %length(linearNeurons),
        
        n
        
        RF_Preference = analysisResults.RFLocation(linearNeurons(n));
        
        if(abs(RF_Preference - (-10)) < 10),
            
            for ep=1:nrOfEyePositionsInTesting,

                % Get response
                [r d] = doPatternPerEyePosition(ep, linearNeurons(n));
                
                % clear out
                r(d > 10) = [];
                d(d > 10) = [];

                responseCell{ep} = [responseCell{ep} r];
                distanceCell{ep} = [distanceCell{ep} d];

            end
        
        end

    end
    
    col =  {'r','b', 'y', 'k'};
    Legends = {['Fixating ' num2str(eyePositions(1)) '^\circ'], ['Fixating ' num2str(eyePositions(2)) '^\circ'], ['Fixating ' num2str(eyePositions(3)) '^\circ'], ['Fixating ' num2str(eyePositions(4)) '^\circ']};
    
    scatterPlotWithMarginalHistograms(distanceCell, responseCell, 'FaceColors', col, 'XTitle', 'Error (deg)', 'YTitle', 'Firing Rate','Legends', Legends, 'YLabelOffset', 0.2);
    %title(num2str(RF_Preference));
    %}
    
    %% Feasability solution
    %{
    h = -10;
    max_h_distance = 10;
    errorbins = 0.5:0.5:20;
    
    for ep=1:nrOfEyePositionsInTesting,
        
        for n=1:100, %length(linearNeurons),
        
            n
    
            % not done

        end

    end
    %}
    
    %% Find perfect cells
    
    h = -10;
    h_capture = 5
    
    f_cutoffs = [0.2, 0.5, 0.8];
    error_max = 10;
    bin_width = 0.1;
    originalTargets = [-63 -45 -27 -9 9 27 45 63]
    
    FaceColors = {[1,0,0],[0,0,1],[0.5,0.5,0.5]}
    
    figure;
    q = 1;
    for h = originalTargets,
        
        errorbins = zeros(length(f_cutoffs), length(bin_width:bin_width:error_max));

        %errorbins = zeros(1, length(bin_width:bin_width:error_max));
        
        for f=1:length(f_cutoffs),
            
            f_cutoff = f_cutoffs(f); % 0.2;

            neuronsQualifying = 0;

            for n=1:length(linearNeurons),

                n;

                RF_Preference = analysisResults.RFLocation(linearNeurons(n));

                % Occurence profile of this neuron
                tmp_bins = zeros(1, length(bin_width:bin_width:error_max));

                if(abs(RF_Preference - h) < h_capture),

                        for ep=1:nrOfEyePositionsInTesting,

                            % Get response
                            [r d] = doPatternPerEyePosition(ep, linearNeurons(n));

                            % clear out responses that are to low
                            d(r > f_cutoff) = [];
                            r(r > f_cutoff) = [];

                            % clear out distances that are to large
                            r(d > error_max) = [];
                            d(d > error_max) = [];

                            % manual counting crap
                            for c=1:length(r),

                                relevant_bins = ceil(d(c)/bin_width):length(tmp_bins);
                                tmp_bins(relevant_bins) =  tmp_bins(relevant_bins)+1;
                            end

                        end

                        neuronsQualifying = neuronsQualifying + 1;

                end

                errorbins(f, :) = errorbins(f, :) + (tmp_bins > 0);

                %errorbins = errorbins + (tmp_bins > 0);
                
            end

            errorbins(f, :) = neuronsQualifying - errorbins(f, :);
            
            %errorbins = neuronsQualifying - errorbins;

            
            disp(['h = ' num2str(h) ',f_cutoff = ' num2str(f_cutoff) ' , neuronsQualifying = ' num2str(neuronsQualifying)]);
            

            objectLegend{f} = ['Threshold ' num2str(f_cutoffs(f))];
            
            %objectLegend{q} = ['Target ' num2str(h)];
            %q = q + 1
            
        end

        figure;
        hBar =  plot(errorbins');% bar(errorbins',1.0,'stacked','LineStyle','none');,'color', FaceColors{i}
        
        xlim([1 length(errorbins)]);
        
        %hold on;
        %plot(errorbins);
    
        
        
        %end
    
        for z=1:length(hBar),
            set(hBar(z),'color', FaceColors{z}); %, {'EdgeColor'}, edgeColors
        end


        %xTick = bin_width:bin_width:error_max;
        binsperdeg = ceil(1/bin_width);
        xTick = binsperdeg:binsperdeg:length(errorbins);
        
        

        for s=1:length(xTick),
            xTickLabels{s} = sprintf([num2str(xTick(s)*bin_width) '%c'], char(176));
        end
        
            
        hYLabel = ylabel('Frequency');
        hXLabel = xlabel('Error (deg)');
        hLegend = legend(objectLegend);
        legend('boxoff');
        set(gca,'XTick', xTick);
        set(gca,'XTickLabel', xTickLabels);
        
        %hTitle = title(['Cell #' num2str(cellNr)]); % ', R:' num2str(region) % ', \Omega_{' num2str(cellNr) '} = ' num2str(sCell)
        set([hYLabel hLegend hXLabel gca], 'FontSize', 16);
        
        %xlim([bin_width length(errorbins)]);
    
    end
    
    
    
    %ylim([0 (max(max(errorbins))+2)]);
    
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
    
    function [r d] = doPatternPerEyePosition(e, theseNeurons)
        
        r=[];
        d=[];
        
        for t = 1:numCombinations,

            [a b] = doPattern(e, t, theseNeurons);
            
            r = [r a'];
            d = [d b'];
            
        end
        
    end

    %% Find false negative neurons
    function yes = noFalseNegatives(errorMargin, responseMargin, theseNeurons)
        
        hasFalseNegatives = zeros(1, length(theseNeurons));
        
        % Old school for loop crap
        for i=1:length(theseNeurons), % neurons
            
            neuronID = theseNeurons(i);
            pref = analysisResults.RFLocation(neuronID);
            
            for t=1:numCombinations, % targets
                for e=1:nrOfEyePositionsInTesting,
                    
                    targetCombinations = targets(allTargetCombinations(t,:));
                    error = min(abs(targetCombinations - pref))';
                    response = squeeze(data(e,t, neuronID));

                    %{
                    if error < errorMargin && response < responseMargin,

                        [I,J] = ind2sub([numRows numCols], neuronID);

                        % 'e,t: (row,col)'
                        disp(['eye=' num2str(e) ',targets=' num2str(targetCombinations) ': (' num2str(I) ',' num2str(J) ')']); % num2str(n)
                        disp(['firing:' num2str(response) ]);
                        disp(['error:' num2str(error) ]);
                        disp(' ');

                        % ban
                        hasFalseNegatives(i) = 1;

                    end
                    
                    %}
                    
                end
            end  
        end
        
        yes = ~hasFalseNegatives;
        
    end
    
    function [response_ distance_ ] = doPattern(e, t, theseNeurons)
        
        nrCells = length(theseNeurons);
        
        % Classic
        response_ = squeeze(data(e,t, theseNeurons));
        
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
        
        distance_ = abs(distance_);

    end
    
end

        
        %{
        %Percentile
        response_ = squeeze(data(e,t, :));
        
        [B,IX] = sort(response_, 'ascend');
        
        v = find(ismember(IX, theseNeurons)); % v is the position in IX where theseNeurns are found, which match the posionts in B where their firingr rates are.
        
        response_ = v/total; % normalize
        %}


        
        %{
        
        %% Find false negative neurons
        for n=1:length(theseNeurons),
            
            [I,J] = ind2sub([numRows numCols], theseNeurons(n));
            
            
            if abs(error(n)) < 5 && response_(n) < 0.2,
                
                % && abs(analysisResults.RFLocation(I,J) - 11) < 5,
                
                % 'e,t: (row,col)'
                disp(['eye=' num2str(e) ',targets=' num2str(targets(allTargetCombinations(t,:))) ': (' num2str(I) ',' num2str(J) ')']); % num2str(n)
                disp(['firing:' num2str(response_(n)) ]);
                disp(['error:' num2str(error(n)) ]);
                disp(' ');
                
                exclude_ = [exclude_ n];
                
            end
            
            
           %{
           if abs(error(n)) > 30 && response_(n) > 0.8, % && abs(analysisResults.RFLocation(I,J) - 11) < 5,
                
                
                disp(['for e,t,n - (row,col):' num2str(e) ',' num2str(t) ',' num2str(n) ' - (' num2str(I) ',' num2str(J) ')' ]);
                
           end
           %}
            
        end
        
        %}
        
        %min((preferredHeadPosition-targetCombinations).^2);
        %sigma = 5;
        %exp(-min(((comparisonvector - repmat(receptivefields,1,numberOfSimultanousTargetsDuringTesting)).^2)')/(2*sigma^2));
        %leastTargetError = leastTargetError';