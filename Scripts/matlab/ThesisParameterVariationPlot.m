%
%  ThesisParameterVariationPlot.m
%  SMI
%
%  Created by Bedeho Mender on 07/11/12.
%  Copyright 2012 OFTNAI. All rights reserved.
%

function ThesisParameterVariationPlot()

    declareGlobalVars();

    global base;
    
    expFolder = [base 'Experiments/' ];
    
    
    %% Baseline
    %{
    experiments(1).Folder   = 'peakedgain/S=0.80_/BlankNetwork';
    X(1)                    = 0;
    names{1}                = '0';
    vals(1)                 = 0;
    for i=1:20,
        experiments(i+1).Folder   = ['peakedgain/S=0.80_/TrainedNetwork_e' num2str(i)];
        X(i+1)                  = i;
        names{i+1}            = num2str(i+1);
        vals(i)                = i;
    end
    XAxislabel = 'Epochs';
    %}
    
    %% varyingfixationsequencelength
    %{
    for i=1:11,
        
        experiments(i).Folder  = ['varyingfixationsequencelength_' num2str(i) '.00/L=0.05000_S=0.80_sS=00000004.50_sT=0.40_gIC=0.0500_eS=0.0_/TrainedNetwork'];
        
        X(i)                   = i;
        XTick(i)               = X(i);
        names{i}               = num2str(i);
        vals(i)                = i;
    end
    XAxislabel = 'Fixation Sequence Length - P';
    %}
    
    %% sparseness
    %{
    vals = 50:2:98;
    for i=1:length(vals),
        experiments(i).Folder   = ['../Experiments_disk/sparseness/S=0.' num2str(vals(i)) '_/TrainedNetwork']; %Blank
        X(i)                    = vals(i);
        XTick(i)                = X(i);
        names{i}                = num2str(i);
    end
    XAxislabel = 'Sparseness Percentile - \pi';
    %}
     
    %% learningrate
    %{
    names = {%'0.00010', '0.00020', '0.00030', '0.00040', '0.00050', '0.00060', '0.00070', '0.00080', '0.00090', ...
             %'0.00100', '0.00200', '0.00300', '0.00400', '0.00500', '0.00600', '0.00700', '0.00800', '0.00900', ...
             '0.01000', '0.02000', '0.03000', '0.04000', '0.05000', '0.06000', '0.07000', '0.08000', '0.09000', ... 
             '0.10000', '0.20000', '0.30000', '0.40000', '0.50000', '0.60000', '0.70000', '0.80000', '0.90000', ...
             '1.00000', '2.00000', '3.00000', '4.00000', '5.00000', '6.00000', '7.00000', '8.00000', '9.00000'}
         
    vals  = [%0.00010, 0.00020, 0.00030, 0.00040, 0.00050, 0.00060, 0.00070, 0.00080, 0.00090, ...
             %0.00100, 0.00200, 0.00300, 0.00400, 0.00500, 0.00600, 0.00700, 0.00800, 0.00900, ...
             0.01000, 0.02000, 0.03000, 0.04000, 0.05000, 0.06000, 0.07000, 0.08000, 0.09000, ... 
             0.10000, 0.20000, 0.30000, 0.40000, 0.50000, 0.60000, 0.70000, 0.80000, 0.90000, ...
             1.00000, 2.00000, 3.00000, 4.00000, 5.00000, 6.00000, 7.00000, 8.00000, 9.00000]
    
    for i=1:length(vals),
        %experiments(i).Folder   = ['learningrate/L=' names{i} '_sS=00000004.50_sT=0.40_/TrainedNetwork'];
        experiments(i).Folder   = ['learningrate/L=' names{i} '_/TrainedNetwork'];
        X(i)                    = vals(i);
    end
    XAxislabel = 'Learning Rate - \rho';
    %}
    
    %% numberOfNeurons_
    %{
    vals = [10 20 30 40 50 60 70];
    for i=1:length(vals),
        experiments(i).Folder   = ['numberOfNeurons_' num2str(vals(i)) '/L=0.05000_S=0.90_sS=00000004.50_sT=0.00_gIC=0.0500_eS=0.0_/BlankNetwork'];
        X(i)                    = vals(i);
        names{i}                = num2str(i);
    end
    %XAxislabel = 'N^{0.5}';
    XAxislabel = '$$\sqrt{N}$$';
    %}
    
    %% varyingheadpositions
    %{
    for i=1:30,
        
        experiments(i).Folder  = ['../Experiments_disk/varyingheadpositions_' num2str(i) '/L=0.05000_S=0.80_sS=00000004.50_sT=0.40_gIC=0.0500_eS=0.0_/TrainedNetwork'];
        X(i)                   = i;
        XTick(i)               = X(i);
        vals(i)                = i;
        names{i}               = num2str(i);
    end
    
    XAxislabel = 'Number of Target Locations - M';
    %}
    
    %% Time constant
    %{
    names  = {'0.010', '0.020', '0.030', '0.040', '0.050', '0.060', '0.070', '0.080', '0.090', ... 
              '0.100', '0.200', '0.300', '0.400', '0.500', '0.600', '0.700', '0.800', '0.900', ...
              '1.000', '2.000', '3.000', '4.000', '5.000', '6.000', '7.000', '8.000', '9.000'};
    vals  = [0.010, 0.020, 0.030, 0.040, 0.050, 0.060, 0.070, 0.080, 0.090, ... 
             0.100, 0.200, 0.300, 0.400, 0.500, 0.600, 0.700, 0.800, 0.900, ...
             1.000, 2.000, 3.000, 4.000, 5.000, 6.000, 7.000, 8.000, 9.000];
         
    
    for i=1:length(vals),
        %../Experiments_disk/tracetimeconstant/ttC=
        % hebb_MANUAL/tC=
        
        experiments(i).Folder   = ['../Experiments_disk/hebb_MANUAL/tC=' names{i}  '_/TrainedNetwork'];
        X(i)                    = vals(i);
    end
    
    %XAxislabel = 'Trace Time Constant - \tau_q (s)';
    XAxislabel = 'Activation Time Constant - \tau_u (s)';
    %}
    
    %% Spatiotemporal Stimulus Dynamics
    %{
    vals = 10:5:75;%;5:100;
    for i=1:length(vals),
        
        experiments(i).Folder   = ['TEST5_search_nonspesific_' num2str(vals(i)) '.00/L=0.05000_S=0.80_sS=00000004.0_sT=0.50_gIC=0.0000_eS=0.0_/TrainedNetwork'];
        X(i)                    = vals(i);
        names{i} = num2str(i);
        
    end
    
    XAxislabel = 'Non-Spesific Period Length - K';
    %}

    %% durationvariability_sigma_0.00
    %{
    vals = 0:0.1:2;
    for i=1:length(vals),
        
        experiments(i).Folder   = ['durationvariability_sigma_' num2str(vals(i),'%.2f') '/L=2.00000_S=0.80_sS=00000004.50_sT=0.400_gIC=0.1500_eS=0.0_/TrainedNetwork'];
        X(i)                    = vals(i);
        names{i}                = num2str(i);
        
    end
    
    XAxislabel = 'Fixation Duration Standard Deviation (s)';
    %}
    
    %% varying_sigma_X
    %{
    for i=1:30,
        
        experiments(i).Folder  = ['../Experiments_disk/varying_sigma_' num2str(i) '.00/L=0.05000_S=0.80_sS=00000004.50_sT=0.40_gIC=0.0500_eS=0.0_/TrainedNetwork'];
        X(i)                   = i;
        XTick(i)               = X(i);
        vals(i)                = i;
        names{i}               = num2str(i);
    end
    
    XAxislabel = 'Receptive Field Size - \sigma (deg)';
    %}
    
    %% prewiredLIPold_selforganization
    %{
        experiments(1).Folder  = 'prewiredLIPold_selforganization/X=1_Y=1/TrainedNetwork_e0';
        X(1)                   = 1;
        XTick(1)               = X(1);
        vals(1)                = 1;
        names{1}               = num2str(1);
        
    for i=2:9,

        experiments(i).Folder  = ['prewiredLIPold_selforganization_deeplook/X=1_Y=1/TrainedNetwork_e1p_' num2str(i-1)];
        X(i)                   = i;
        XTick(i)               = X(i-1);
        vals(i)                = i-1;
        names{i}               = num2str(i-1);
    end
    
    XAxislabel = 'Periode';
    %}
    
    %% prewiredLIPold_selforganization
    %{
    for i=1:10,

        experiments(i).Folder  = ['prewiredLIPold_selforganization/X=1_Y=1/TrainedNetwork_e' num2str(i)];
        X(i)                   = i;
        XTick(i)               = X(i);
        vals(i)                = i;
        names{i}               = num2str(i);
    end
    
    XAxislabel = 'Epoch';
    %}
    
    %% varyingsigmoidrate_x
    %{
    vals = 0:0.1:1;
    for i=1:length(vals),
        
        experiments(i).Folder   = ['varyingsigmoidrate_' sprintf('%.2f',vals(i)) '/L=0.05000_S=0.80_sS=00000004.50_sT=0.400_gIC=0.0000_eS=0.0_/BlankNetwork'];
        X(i)                    = vals(i);
        names{i}                = num2str(i);
        
    end
    
    XAxislabel = 'Sigmoid Modulation Rate';
    %}
    
    %% Plotting
    numExperiments = length(experiments);
    
    % Data
    AverageHeadCenteredNess = zeros(1, numExperiments);
    AverageHeadCenteredNessSTD = zeros(1, numExperiments);
    
    headCenteredNessRate = zeros(1,numExperiments);
    rfSizes = zeros(1,numExperiments);
    rfSizesSTD = zeros(1,numExperiments);
    coverage = zeros(1,numExperiments);
    
    % Load baseline
    disp('Exp: untrained ----------------------');
    %[c_,h_,r_,r_std_,a_,a_std_] = loadExperiment([expFolder '../Experiments_disk/varyingfixationsequencelength_' num2str(i) '.00/L=0.05000_S=0.80_sS=00000004.50_sT=0.40_gIC=0.0500_eS=0.0_/BlankNetwork/analysisResults.mat']);
    %[c_,h_,r_,r_std_,a_,a_std_] = loadExperiment([expFolder '../Experiments_disk/tracetimeconstant/ttC=0.010_/BlankNetwork/analysisResults.mat']);
    %[c_,h_,r_,r_std_,a_,a_std_] = loadExperiment([expFolder '../Experiments_disk/sparseness/S=0.52_/BlankNetwork/analysisResults.mat']);
    %[c_,h_,r_,r_std_,a_,a_std_] = loadExperiment([expFolder '../Experiments_disk/varyingheadpositions_1/L=0.05000_S=0.80_sS=00000004.50_sT=0.40_gIC=0.0500_eS=0.0_/BlankNetwork/analysisResults.mat']);
    %[c_,h_,r_,r_std_,a_,a_std_] = loadExperiment([expFolder '../Experiments_disk/varying_sigma_1.00/L=0.05000_S=0.80_sS=00000004.50_sT=0.40_gIC=0.0500_eS=0.0_/BlankNetwork/analysisResults.mat']);
    %[c_,h_,r_,r_std_,a_,a_std_] = loadExperiment([expFolder 'TEST5_search_nonspesific_70.00/L=0.05000_S=0.80_sS=00000004.0_sT=0.50_gIC=0.0000_eS=0.0_/BlankNetwork/analysisResults.mat']);
    %[c_,h_,r_,r_std_,a_,a_std_] = loadExperiment([expFolder 'durationvariability_sigma_0.00/L=2.00000_S=0.80_sS=00000004.50_sT=0.400_gIC=0.1500_eS=0.0_/BlankNetwork/analysisResults.mat']);
    %[c_,h_,r_,r_std_,a_,a_std_] = loadExperiment([expFolder 'prewiredLIPold_selforganization/X=1_Y=1/TrainedNetwork_e0/analysisResults.mat']);
    %[c_,h_,r_,r_std_,a_,a_std_] = loadExperiment([expFolder 'prewiredLIPold_selforganization/X=1_Y=1/TrainedNetwork_e0/analysisResults.mat']);
    
    % Iterate experiments and plot
    for e = 1:numExperiments,

        % Load analysis file for experiments
        disp(['Exp: ' names{e} '----------------------']);
        [c,h,r,r_std,a,a_std] = loadExperiment([expFolder experiments(e).Folder '/analysisResults.mat']);
        
        % Save data
        coverage(e) = c;
        headCenteredNessRate(e) = h;
        rfSizes(e) = r;
        rfSizesSTD(e) = r_std;
        AverageHeadCenteredNess(e)  = a;
        AverageHeadCenteredNessSTD(e) = a_std;
        
        %[expFolder experiments(e).Folder '/analysisResults.mat']
        %headCenteredNess(e) = res.fractionVeryHeadCentered;
        %rf = res.RFSize_Linear_Clean(res.headCenteredNess_Linear_Clean >= 0.7);
        %rfSizes(e) = mean(rf);
    end
    
    XLim = [vals(1) vals(end)];

    %% Log plots
    %{
    
    %Limits
    
    Y1min = min(r_,min(rfSizes - rfSizesSTD/2)) - 2; %classic=2
    Y2min = min(a_,min(AverageHeadCenteredNess - AverageHeadCenteredNessSTD/2)) - 0.1; % clssic: 0.1s
    
    Y1max = max(r_, max(rfSizes + rfSizesSTD/2)) + 2;%classic=2
    Y2max = max(a_, max(AverageHeadCenteredNess + AverageHeadCenteredNessSTD/2)) + 0.1; % clssic: 0.1s
    
    % Plot 1
    figure();
    [AX,H1,H2] = plotyy(X, headCenteredNessRate, X, coverage); % ,'semilogx'
    
    axes(AX(1));
    set(AX(1),'XLim', XLim, 'YLim', [0 1], 'YTick', 0:0.2:1); % ,'XGrid','on'
    
    axes(AX(2));
    set(AX(2),'XLim', XLim, 'YLim', [0 1], 'YTick', 0:0.2:1); % ,'XGrid','on'   
    
    % Add untrained
    axes(AX(1));
    hold(AX(1), 'on');
    %plot(XLim,[h_ h_],'--','Color','b');
    axes(AX(2));
    hold(AX(2), 'on');
    %plot(XLim,[c_ c_],'--','Color','g');
    
    % Prettyup
    pretty(AX, XAxislabel,'Head-Centeredness Rate','Coverage');
    
    % Errorbars in plot 2
    figure();
    
    [AX,H1,H2] = plotyy(X, rfSizes,X, AverageHeadCenteredNess); % ,'semilogx'  
    
    % Errorbars
    axes(AX(1));
    hold(AX(1), 'on');
    errorbar(AX(1), X, rfSizes, -rfSizesSTD/2, rfSizesSTD/2,'Color','k','Parent', AX(1));
    %plot(XLim,[r_ r_],'--','Color','k'); % Add untrained
    set(AX(1),'YColor','k','YLim', [0 100],'XLim', XLim,'YTick', 0:20:100); % roundn(linspace(Y1min,Y1max,5),0) ,'XGrid','on'
    
    axes(AX(2));
    hold(AX(2), 'on');
    errorbar(AX(2), X, AverageHeadCenteredNess, -AverageHeadCenteredNessSTD/2, AverageHeadCenteredNessSTD/2,'Color','r','Parent',AX(2));
    %plot(XLim,[a_ a_],'--','Color','r'); % Add untrained
    set(AX(2),'YColor','r','YLim', [0 1],'XLim', XLim, 'YTick', 0:0.2:1); %, 'YTick', roundn(linspace(Y2min,Y2max,5),-2)); % ,'XGrid','on'

    % Prettyup
    pretty(AX, XAxislabel,'Average Receptive Field Size (deg)','Average Head-Centeredness');

    function pretty(AX, XAxislabel, Y1Axislabel, Y2Axislabel) 
        
        % Labels
        hXLabel = xlabel(XAxislabel);

        hYLabel1 = get(AX(1),'Ylabel');
        set(hYLabel1,'String', Y1Axislabel);

        hYLabel2 = get(AX(2),'Ylabel');
        set(hYLabel2,'String', Y2Axislabel);

        set([AX hXLabel hYLabel1 hYLabel2], 'FontSize', 14);
        
    end
    %}
    
    
    %% Combined 4yyyy
    
    
    [ax,hlines] = ploty4(X,headCenteredNessRate,X,coverage,X,AverageHeadCenteredNess,X,rfSizes,{'Head-Centeredness Rate','Coverage','Average Head-Centeredness','Average Receptive Field Size (deg)'}, XAxislabel, AverageHeadCenteredNessSTD,rfSizesSTD,XLim); 
    
    set(ax(4),'YLim', [0 80]);%[Y1min Y1max]);
    set(ax(3),'YLim', [0 1]);%[Y2min Y2max]);
    
    % Add untrained
    %{
    hold(ax(1), 'on');
    plot(ax(1),XLim,[h_ h_],'--','Color','b');
    
    hold(ax(2), 'on');
    plot(ax(2),XLim,[c_ c_],'--','Color','g');
    
    hold(ax(3), 'on');
    plot(ax(3),XLim,[a_ a_],'--','Color','r');
    
    hold(ax(4), 'on');
    plot(ax(4),XLim,[r_ r_],'--','Color','k');
    %}
    
        
    %if(exist('XTick')),
    %    set(AX,'XTick', XTick);
    %end
    
    % timeconstant
    %axis(AX,[0.010 10.000 0 0.4]);

    % sparseness
    %axis(AX(1),[50 98 0 1]);
    %axis(AX(2),[50 98 20 60]);
   
    %% Load experiment
    function [c,h,r,r_std,a,a_std] =  loadExperiment(analysisPath)
    
        % Load analysis file for experiments
        collation = load(analysisPath);
        res = collation.analysisResults;
        
        % Save data
        c = res.uniformity;
        h = res.HC;
        r = mean(res.RFSize_HC);
        r_std = std(res.RFSize_HC);
        a = mean(res.headCenteredNess_HC);
        a_std = std(res.headCenteredNess_HC);
        
        %Dump
        disp(['coverage: ' num2str(c)]);
        disp(['headCenteredNessRate: ' num2str(h)]);
        disp(['rfSizes: ' num2str(r)]);
        disp(['AverageHeadCenteredNess: ' num2str(a)]);
    end
end
  
