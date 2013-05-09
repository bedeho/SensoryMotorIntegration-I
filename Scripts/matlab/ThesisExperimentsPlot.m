%
%  ThesisExperimentsPlot.m
%  SMI
%
%  Created by Bedeho Mender on 06/11/12.
%  Copyright 2012 OFTNAI. All rights reserved.
%

function ThesisExperimentsPlot()

    declareGlobalVars();

    global base;
    
     
    %% prewiredPO
    %{
    Experiment = 'prewiredPO';
    experiment(1).Name = 'Random';
    experiment(1).Folder = expFolder('prewiredPO/X=1_Y=1/BlankNetwork');
    experiment(2).Name = 'Prewired';
    experiment(2).Folder = expFolder('prewiredPO/X=1_Y=1/TrainedNetwork');
    %FaceColors = {[1,0,0]; [0,0,1]};
    FaceColors = {[67,82,163]/255; [238,48,44]/255};
    %}
    
    %% peakedgain
    %{
    Experiment = 'peakedgain';
    experiment(1).Name = 'Untrained';
    experiment(1).Folder = expFolder('peakedgain/S=0.80_/BlankNetwork');
    experiment(2).Name = '10 Epochs';
    experiment(2).Folder = expFolder('peakedgain/S=0.80_/TrainedNetwork_e10'); 
    experiment(3).Name = '20 Epochs';
    experiment(3).Folder = expFolder('peakedgain/S=0.80_/TrainedNetwork'); 
    %FaceColors = {[1,0,0]; [0.5,0,0.5]; [0,0,1]};
    FaceColors = {[67,82,163]/255; [152,65,103]/255; [238,48,44]/255};
    %}
    
    %% learningrate
    %{
    Experiment = 'learningrate';
    experiment(1).Name = 'Random';
    experiment(1).Folder = expFolder('learningrate/L=9.00000_/TrainedNetwork');
    FaceColors = {[1,0,0]};
    %}
    
    %% sigma_19_failed
    %{
    Experiment = 'sigma_19_failed';
    experiment(1).Name = 'sigma_19_failed';
    experiment(1).Folder = expFolder('sigma_19_failed/L=0.05000_S=0.90_sS=00000004.50_sT=0.00_gIC=0.0500_eS=0.0_/TrainedNetwork');
    FaceColors = {[1,0,0]};
    %}
    
    %% nonlinear_activation_5
    %{
    Experiment = 'nonlinear_activation_5';
    experiment(1).Name = 'Untrained';
    experiment(1).Folder = expFolder('nonlinear_activation_5/L=0.05000_S=0.90_sS=00000050.0_sT=0.02_gIC=0.0500_eS=0.0_/BlankNetwork');
    experiment(2).Name = 'Trained';
    experiment(2).Folder = expFolder('nonlinear_activation_5/L=0.05000_S=0.90_sS=00000050.0_sT=0.02_gIC=0.0500_eS=0.0_/TrainedNetwork');
    FaceColors = {[1,0,0]; [0,0,1]};
    %}

    %% decoupled_gainencoding
    %{
    Experiment = 'decoupled_gainencoding';
    experiment(1).Name = 'Untrained';
    experiment(1).Folder = expFolder('decoupled_gainencoding/L=0.05000_S=0.90_sS=00000004.50_sT=0.00_gIC=0.0500_eS=0.0_/BlankNetwork');
    experiment(2).Name = 'Trained';
    experiment(2).Folder = expFolder('decoupled_gainencoding/L=0.05000_S=0.90_sS=00000004.50_sT=0.00_gIC=0.0500_eS=0.0_/TrainedNetwork');
    FaceColors = {[67,82,163]/255; [238,48,44]/255};
    %}
    
    %% multitargettraining_retune
    %{
    Experiment = 'multitargettraining_retune';
    experiment(1).Name = 'Untrained';
    experiment(1).Folder = expFolder('multitargettraining_retune/S=0.80_sS=00000015.0_sT=0.15_/BlankNetwork');
    experiment(2).Name = 'Trained';
    experiment(2).Folder = expFolder('multitargettraining_retune/S=0.80_sS=00000015.0_sT=0.15_/TrainedNetwork');
    FaceColors = {[1,0,0]; [0,0,1]};
    %}
    
    %% 8H_13E_FIX1200ms
    %{
    Experiment = '8H_13E_FIX1200ms';
    experiment(1).Name = 'Untrained';
    experiment(1).Folder = expFolder('8H_13E_FIX1200ms/sT=0.40_/BlankNetwork');
    experiment(2).Name = 'Trained';
    experiment(2).Folder = expFolder('8H_13E_FIX1200ms/sT=0.40_/TrainedNetwork');
    FaceColors = {[1,0,0]; [0,0,1]};
    %}
    
    %% 8H_13E_FIX1200ms-w-0.1
    %{
    Experiment = '8H_13E_FIX1200ms-w-0.1';
    experiment(1).Name = 'Untrained';
    experiment(1).Folder = expFolder('8H_13E_FIX1200ms-w-0.1/L=0.90000_S=0.80_sS=00000006.0_sT=0.40_gIC=0.0500_eS=0.0_/BlankNetwork');
    experiment(2).Name = 'Trained';
    experiment(2).Folder = expFolder('8H_13E_FIX1200ms-w-0.1/L=0.90000_S=0.80_sS=00000006.0_sT=0.40_gIC=0.0500_eS=0.0_/TrainedNetwork');
    FaceColors = {[1,0,0]; [0,0,1]};
    %}
    
    %% 8H_13E_FIX1200ms-w-0.1-covariance-TUNE
    %{
    Experiment = '8H_13E_FIX1200ms-w-0.1-covariance-TUNE';
    experiment(1).Name = 'Untrained';
    experiment(1).Folder = expFolder('8H_13E_FIX1200ms-w-0.1-covariance-TUNE/S=0.90_sT=0.10_/BlankNetwork');
    experiment(2).Name = 'Trained';
    experiment(2).Folder = expFolder('8H_13E_FIX1200ms-w-0.1-covariance-TUNE/S=0.90_sT=0.10_/TrainedNetwork');
    FaceColors = {[1,0,0]; [0,0,1]};
    %}
    
    %% singlerandomepeak/sS=00000007.0_sT=0.05_
    %{
    Experiment = 'singlerandomepeak';
    experiment(1).Name = 'Untrained';
    experiment(1).Folder = expFolder('singlerandomepeak/sS=00000007.0_sT=0.05_/BlankNetwork');
    experiment(2).Name = 'Trained';
    experiment(2).Folder = expFolder('singlerandomepeak/sS=00000007.0_sT=0.05_/TrainedNetwork');
    FaceColors = {[1,0,0]; [0,0,1]};
    %}
    
    %% doublepeak_0.30/L=0.05000_S=0.90_sS=00000004.50_sT=0.10_gIC=0.0500_eS=0.0_
    %{
    Experiment = 'doublepeak_0.30';
    experiment(1).Name = 'Untrained';
    experiment(1).Folder = expFolder('doublepeak_0.30/L=0.05000_S=0.90_sS=00000004.50_sT=0.10_gIC=0.0500_eS=0.0_/BlankNetwork');
    experiment(2).Name = 'Trained';
    experiment(2).Folder = expFolder('doublepeak_0.30/L=0.05000_S=0.90_sS=00000004.50_sT=0.10_gIC=0.0500_eS=0.0_/TrainedNetwork');
    FaceColors = {[1,0,0]; [0,0,1]};
    %}
    
    %% global_slopetuning/sS=00000003.0_
    
    Experiment = 'global_slopetuning';
    experiment(1).Name = 'Untrained';
    experiment(1).Folder = expFolder('global_slopetuning/sS=00000003.0_/BlankNetwork');
    experiment(2).Name = 'Trained';
    experiment(2).Folder = expFolder('global_slopetuning/sS=00000003.0_/TrainedNetwork');
    FaceColors = {[67,82,163]/255; [238,48,44]/255};
    
    
    %% planargain/L=0.05000_S=0.90_sS=00000004.50_sT=0.00_gIC=0.0000_eS=0.0_
    %{
    Experiment = 'planargain';
    experiment(1).Name = 'Untrained';
    experiment(1).Folder = expFolder('planargain/L=0.05000_S=0.90_sS=00000004.50_sT=0.00_gIC=0.0000_eS=0.0_/BlankNetwork');
    experiment(2).Name = 'Trained';
    experiment(2).Folder = expFolder('planargain/L=0.05000_S=0.90_sS=00000004.50_sT=0.00_gIC=0.0000_eS=0.0_/TrainedNetwork');
    FaceColors = {[1,0,0]; [0,0,1]};
    %}
    
    %% prewiredLIPnew/X=1_Y=1
    %{
    Experiment = 'prewiredLIPnew';
    experiment(1).Name = 'Untrained';
    experiment(1).Folder = expFolder('prewiredLIPnew/X=1_Y=1/BlankNetwork');
    experiment(2).Name = 'Trained';
    experiment(2).Folder = expFolder('prewiredLIPnew/X=1_Y=1/TrainedNetwork');
    FaceColors = {[1,0,0]; [0,0,1]};
    %}
    
    %% prewiredLIPold/X=1_Y=1
    %{
    Experiment = 'prewiredLIPold';
    experiment(1).Name = 'Untrained';
    experiment(1).Folder = expFolder('prewiredLIPold/X=1_Y=1/BlankNetwork');
    experiment(2).Name = 'Trained';
    experiment(2).Folder = expFolder('prewiredLIPold/X=1_Y=1/TrainedNetwork');
    FaceColors = {[1,0,0]; [0,0,1]};
    %}
    
    %% prewiredLIPnew_selforganization/X=1_Y=1
    %{
    Experiment = 'prewiredLIPnew_selforganization';
    experiment(1).Name = 'Hardwired';
    experiment(1).Folder = expFolder('prewiredLIPnew_selforganization/X=1_Y=1/TrainedNetwork_e0');
    experiment(2).Name = '10 Epochs';
    experiment(2).Folder = expFolder('prewiredLIPnew_selforganization/X=1_Y=1/TrainedNetwork_e10');
    FaceColors = {[1,0,0]; [0,0,1]};
    %}
    
    %% prewiredLIPnew_selforganization/X=1_Y=1
    %{
    Experiment = 'prewiredLIPnew_selforganization';
    experiment(1).Name = 'Hardwired';
    experiment(1).Folder = expFolder('prewiredLIPold_selforganization/X=1_Y=1/TrainedNetwork_e0');
    experiment(2).Name = '10 Epochs';
    experiment(2).Folder = expFolder('prewiredLIPold_selforganization/X=1_Y=1/TrainedNetwork_e10');
    FaceColors = {[1,0,0]; [0,0,1]};
    %}
    
    %% planargain_insideepochlook/L=0.05000_S=0.90_sS=00000004.50_sT=0.00_gIC=0.0000_eS=0.0_
    %{
    Experiment = 'planargain_insideepochlook';
    experiment(1).Name = 'TrainedNetwork_e1p_1';
    experiment(1).Folder = expFolder('planargain_insideepochlook/L=0.05000_S=0.90_sS=00000004.50_sT=0.00_gIC=0.0000_eS=0.0_/TrainedNetwork_e1p_1');
    experiment(2).Name = 'TrainedNetwork_e1p_2';
    experiment(2).Folder = expFolder('planargain_insideepochlook/L=0.05000_S=0.90_sS=00000004.50_sT=0.00_gIC=0.0000_eS=0.0_/TrainedNetwork_e1p_2');
    experiment(3).Name = 'TrainedNetwork_e1p_3';
    experiment(3).Folder = expFolder('planargain_insideepochlook/L=0.05000_S=0.90_sS=00000004.50_sT=0.00_gIC=0.0000_eS=0.0_/TrainedNetwork_e1p_3');    
    experiment(4).Name = 'TrainedNetwork_e1p_4';
    experiment(4).Folder = expFolder('planargain_insideepochlook/L=0.05000_S=0.90_sS=00000004.50_sT=0.00_gIC=0.0000_eS=0.0_/TrainedNetwork_e1p_4');
    experiment(5).Name = 'TrainedNetwork_e1p_5';
    experiment(5).Folder = expFolder('planargain_insideepochlook/L=0.05000_S=0.90_sS=00000004.50_sT=0.00_gIC=0.0000_eS=0.0_/TrainedNetwork_e1p_5');
    experiment(6).Name = 'TrainedNetwork_e1p_6';
    experiment(6).Folder = expFolder('planargain_insideepochlook/L=0.05000_S=0.90_sS=00000004.50_sT=0.00_gIC=0.0000_eS=0.0_/TrainedNetwork_e1p_6');
    experiment(7).Name = 'TrainedNetwork_e1p_7';
    experiment(7).Folder = expFolder('planargain_insideepochlook/L=0.05000_S=0.90_sS=00000004.50_sT=0.00_gIC=0.0000_eS=0.0_/TrainedNetwork_e1p_7');
    experiment(8).Name = 'TrainedNetwork_e1p_8';
    experiment(8).Folder = expFolder('planargain_insideepochlook/L=0.05000_S=0.90_sS=00000004.50_sT=0.00_gIC=0.0000_eS=0.0_/TrainedNetwork_e1p_8');
    FaceColors = {[1,0,0]; [0,0,1]; [1,0,0]; [1,0,0]; [1,0,0]; [1,0,0]; [1,0,0]; [1,0,0];};
    %}
    
    %% sigma_19_selforganization_biggerEyeDimension/sT=0.02_
    %{
    Experiment = 'sigma_19_selforganization_biggerEyeDimension';
    experiment(1).Name = 'Untrained';
    experiment(1).Folder = expFolder('sigma_19_selforganization_biggerEyeDimension/sT=0.02_/BlankNetwork');
    experiment(2).Name = 'TrainedNetwork';
    experiment(2).Folder = expFolder('sigma_19_selforganization_biggerEyeDimension/sT=0.02_/TrainedNetwork');
    FaceColors = {[1,0,0],[0,0,1]};
    %}
    
    %% Dont need to touch anything below here.
    numExperiments = length(experiment);
    
    % Allocate buffer space
    headCenteredNess    = cell(1,numExperiments);
    eyeCenteredNess     = cell(1,numExperiments);
    Index               = cell(1,numExperiments);
    RFLocation          = cell(1,numExperiments);
    RFSize              = cell(1,numExperiments);
    
    headCenteredNess_HC = cell(1,numExperiments);
    eyeCenteredNess_HC  = cell(1,numExperiments);
    Index_HC            = cell(1,numExperiments);
    RFLocation_HC       = cell(1,numExperiments);
    RFSize_HC           = cell(1,numExperiments);    
    
    Legends = cell(1,numExperiments);
    
    %Summary
    %IndexTrack = [];
    minEye = 0;
    minHead = 0;
    maxSize = -inf;
    minSize = inf;
    maxLocation = -inf;
    minLocation = inf;
    numberOfIndexBins = 40;
    indexBins = linspace(-1, 1, numberOfIndexBins+1);
    IndexDistributions = zeros(numExperiments, numberOfIndexBins);
    preferredTargetDistributions = [];
    trainingTargets = [];
    
    % Table summary
    headCenteredNess_summary    = zeros(4,numExperiments);%(all_mean,all_std,HC_mean,HC_std)
    eyeCenteredNess_summary     = zeros(4,numExperiments);
    Index_summary               = zeros(4,numExperiments);
    RFLocation_summary          = zeros(4,numExperiments);
    RFSize_summary              = zeros(4,numExperiments);
    
    % Iterate experiments and plot
    for e = 1:numExperiments,

        % Load analysis file for experiments
        data = load([experiment(e).Folder '/analysisResults.mat']);
        
        % Project out data
        headCenteredNess{e} = data.analysisResults.headCenteredNess_Linear_Clean;
        headCenteredNess_HC{e} = data.analysisResults.headCenteredNess_HC;
        
        minHead = min(minHead, min(headCenteredNess{e}));
        
        x = data.analysisResults;
        if(isfield(x,'eyeCenteredNess_Linear_Clean')),
            eyeCenteredNess{e} = data.analysisResults.eyeCenteredNess_Linear_Clean;
            eyeCenteredNess_HC{e} = data.analysisResults.eyeCenteredNess_HC;
            minEye = min(minEye, min(eyeCenteredNess{e}));
            Index{e} = data.analysisResults.Index_Linear_Clean;
            Index_HC{e} = data.analysisResults.Index_HC;
            
            % SAve index distribution
            hx = histc(Index{e}, indexBins);
            IndexDistributions(e,:) = hx(1:(end-1))./ sum(hx(1:(end-1)));
            
            % Save preferred target distribution
            preferredTargetDistributions = [preferredTargetDistributions; data.analysisResults.preferredTargetDistribution];
            trainingTargets = data.analysisResults.trainingTargets;
            
                        %index = x.headCenteredNess_Linear; %x.eyeCenteredNess_Linear %(x.eyeCenteredNess_Linear - x.headCenteredNess_Linear)./(x.eyeCenteredNess_Linear + x.headCenteredNess_Linear);
            %IndexTrack = [IndexTrack; index'];
        end
        
        RFLocation{e} = data.analysisResults.RFLocation_Linear_Clean;
        RFSize{e} = data.analysisResults.RFSize_Linear_Clean;
        
        RFLocation_HC{e} = data.analysisResults.RFLocation_HC;
        RFSize_HC{e} = data.analysisResults.RFSize_HC;
        
        maxSize = max(maxSize, max(RFSize_HC{e}));
        minSize = min(minSize, min(RFSize_HC{e}));
        
        maxLocation = max(maxLocation, max(RFLocation_HC{e}));
        minLocation = min(minLocation, min(RFLocation_HC{e}));
    
        
        % Check that we have non-empty dataset
        if(isempty(headCenteredNess{e})),
            error(['Empty data set found' experiment(e).Name]);
        end
        
        % Populate legend cell
        Legends{e} = experiment(e).Name;
        
        % Make table summary
        headCenteredNess_summary(1,e) = mean(headCenteredNess{e});
        headCenteredNess_summary(2,e) = std(headCenteredNess{e});
        headCenteredNess_summary(3,e) = mean(headCenteredNess_HC{e});
        headCenteredNess_summary(4,e) = std(headCenteredNess_HC{e});
        
        eyeCenteredNess_summary(1,e) = mean(eyeCenteredNess{e});
        eyeCenteredNess_summary(2,e) = std(eyeCenteredNess{e});
        eyeCenteredNess_summary(3,e) = mean(eyeCenteredNess_HC{e});
        eyeCenteredNess_summary(4,e) = std(eyeCenteredNess_HC{e});
        
        Index_summary(1,e) = mean(Index{e});
        Index_summary(2,e) = std(Index{e});        
        Index_summary(3,e) = mean(Index_HC{e});
        Index_summary(4,e) = std(Index_HC{e}); 
        
        RFLocation_summary(1,e) = mean(RFLocation{e});
        RFLocation_summary(2,e) = std(RFLocation{e});   
        RFLocation_summary(3,e) = mean(RFLocation_HC{e});
        RFLocation_summary(4,e) = std(RFLocation_HC{e}); 

        RFSize_summary(1,e) = mean(RFSize{e});
        RFSize_summary(2,e) = std(RFSize{e});
        RFSize_summary(3,e) = mean(RFSize_HC{e});
        RFSize_summary(4,e) = std(RFSize_HC{e});
        
        % Mini summary
        disp([experiment(e).Name ':']);
        disp('--------------------------------------');
        disp(['Is Head-centered: ' num2str(data.analysisResults.HC)]);
        disp(['Uniformity(Normalized entropy): ' num2str(data.analysisResults.uniformity)]);
        disp(['Fraction discarded: ' num2str(data.analysisResults.fractionDiscarded)]);

    end
    disp('--------------------------------------');
    
    %% Make table dump    
    dumptableline('Head-centeredness', headCenteredNess_summary,0);
    dumptableline('Eye-centeredness', eyeCenteredNess_summary,0);
    dumptableline('RFI', Index_summary, 0);
    dumptableline('RF Location', RFLocation_summary ,1);
    dumptableline('RF Size', RFSize_summary,1);
    
    function dumptableline(title, data, addcirc)
        
        str = [title char(9)];
        
        for e = 1:numExperiments,
            if addcirc
                str = sprintf('%s & \t $%.2f^\\circ$ $(%.2f^\\circ)$ & \t $%.2f^\\circ$ $(%.2f^\\circ)$', str, data(1,e), data(2,e), data(3,e), data(4,e));
            else
                str = sprintf('%s & \t $%.2f$ $(%.2f)$ & \t $%.2f$ $(%.2f)$', str, data(1,e), data(2,e), data(3,e), data(4,e));
            end
        end
        
        disp([str ' \\']);
    end
    
    %scatterPlotWithMarginalHistograms(RFLocation, headCenteredNess, 'XTitle', 'Receptive Field Location (deg)', 'YTitle', 'Head-Centeredness', 'Legends', Legends,'YLabelOffset', 3, 'FaceColors', FaceColors);
    
    %% Receptive Field
    [receptivefieldPlot, yProjectionAxis, scatterAxis, xProjectionAxis, XLim, YLim] = scatterPlotWithMarginalHistograms(RFLocation_HC, RFSize_HC, 'XTitle', 'Receptive Field Location (deg)', 'YTitle', 'Receptive Field Size (deg)', 'Legends', Legends ,'FaceColors', FaceColors, 'Location', 'NorthEast');
    %size_ticks = 10*(idivide(int32(minSize),10,'floor'):1:idivide(int32(maxSize),10,'ceil'));
    %rflocation_ticks = 10*(idivide(int32(minLocation),10,'floor'):1:idivide(int32(maxLocation),10,'ceil'));
    axes(scatterAxis);
    grid off
    %set(gca,'XTick', rflocation_ticks);
    %set(gca,'YTick', size_ticks);
        
    
    if(isfield(x,'eyeCenteredNess_Linear_Clean')),
        
        %% Reference Frame
        minVal = min(minEye,minHead);
        
        [referenceframePlot, yProjectionAxis, scatterAxis, xProjectionAxis, XLim, YLim] = scatterPlotWithMarginalHistograms(eyeCenteredNess, headCenteredNess, 'XTitle', 'Eye-Centeredness', 'YTitle', 'Head-Centeredness', 'Legends', Legends , 'FaceColors', FaceColors, 'XLim', [minVal 1], 'YLim', [minVal 1]);
        axes(scatterAxis);

        ticks = fliplr(1:-0.2:minVal);
        
        set(gca,'XTick', ticks);
        set(gca,'YTick', ticks);
        hold on
        plot([minVal 1],[minVal 1],'--k');
        
        %figure;
        %plot(IndexTrack);
        
        %% Index distributions
        RFdistributionPlot = figure();
        hBar = bar(indexBins(2:end), IndexDistributions', 1.0, 'stacked', 'LineStyle', 'none'); 
        for i=1:length(hBar),
            set(hBar(i),'FaceColor', FaceColors{i}); %, {'EdgeColor'}, edgeColors
        end
        box off;
        hYLabel = ylabel('Frequency');
        hXLabel = xlabel('RFI');
        hLegend = legend(Legends);
        legend boxoff
        set([hLegend gca], 'FontSize', 16);
        set([hYLabel hXLabel], 'FontSize', 20);
        xlim([-1,1]);
        axis square
        axis tight;
        
        % Coverage
        coveragePlot = figure();
        hBar = bar(preferredTargetDistributions','LineStyle','none');
        for i=1:length(hBar),
            set(hBar(i),'FaceColor', FaceColors{i}); %, {'EdgeColor'}, edgeColors
        end
        box off;
        hYLabel = ylabel('Frequency');
        hXLabel = xlabel('Head-Centered Training Location (deg)');
        hLegend = legend(Legends);
        legend boxoff
        set(gca,'XTickLabel', trainingTargets);
        set([hLegend gca], 'FontSize', 16);
        set([hYLabel hXLabel], 'FontSize', 20);
        axis tight
        axis square
        
    end
    
    choice = questdlg('Save to Thesis?', ...
	'Save to Thesis', ...
	'Noooooooo!','Chap 2','Chap 3'); % 'Chap 4','Chap 6','Chap 7'

    % Handle response
    switch choice
        case 'Chap 2'
            chapnr = 2;
        case 'Chap 3'
            chapnr = 3;
        case 'Chap 4'
            chapnr = 4;
        case 'Chap 6'
            chapnr = 6;
        case 'Chap 7'
            chapnr = 7;
    end
    
    chapter_dir = ['/Network/Servers/mac0.cns.ox.ac.uk/Volumes/Data/Users/mender/Dphil/Thesis/figures/chap-' num2str(chapnr) '/'];
    
    saveas(receptivefieldPlot, [chapter_dir Experiment '_receptivefield.eps'], 'epsc');
    saveas(referenceframePlot, [chapter_dir Experiment '_referenceframe.eps'], 'epsc');
    saveas(RFdistributionPlot, [chapter_dir Experiment '_RFdistribution.eps'], 'epsc');
    saveas(coveragePlot, [chapter_dir Experiment '_coverage.eps'], 'epsc');
    
    function folder = expFolder(name)
        folder = [base 'Experiments/' name];
    end

end
