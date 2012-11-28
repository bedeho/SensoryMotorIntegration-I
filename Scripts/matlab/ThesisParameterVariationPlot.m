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
    experiments(1).Folder   =   'peakedgain/S=0.80_/BlankNetwork';
    X(1)                    =    0;
    
    for i=1:20,
        experiments(i+1).Folder   = ['peakedgain/S=0.80_/TrainedNetwork_e' num2str(i)];
        X(i)                  = i;
    end
    XAxislabel = 'Epochs';
    %}
    
    %% varyingfixationsequencelength [_TRACERESET]
    %{
    for i=1:11,
        
        experiments(i).Folder   = ['varyingfixationsequencelength_' num2str(i) '.00/L=0.05000_S=0.80_sS=00000004.50_sT=0.40_gIC=0.0500_eS=0.0_/TrainedNetwork_e10'];
        
        %experiments(i).Folder  = ['varyingfixationsequencelength_' num2str(i) '.00_TRACERESET/L=0.05000_S=0.80_sS=00000004.50_sT=0.40_gIC=0.0500_eS=0.0_/TrainedNetwork'];
        
        X(i)                    = i;
    end
    XAxislabel = 'Fixation Sequence Length (?)';
    %}
    
    %% sparseness
    %{
    vals = 50:2:98;
    for i=1:length(vals),
        experiments(i).Folder   = ['sparseness/S=0.' num2str(vals(i)) '_/TrainedNetwork_e11'];
        X(i)                    = i;
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
        experiments(i).Folder   = ['learningrate/L=' names{i} '_/TrainedNetwork'];
        X(i)                    = vals(i);
    end
    XAxislabel = 'Learning Rate - \rho';
    XTick = [0.01 0.09 0.9 9.0];
    %}
    
    %% varyingheadpositions
    %{
    for i=1:30,
        
        experiments(i).Folder   = ['varyingheadpositions_' num2str(i) '/L=0.05000_S=0.80_sS=00000004.50_sT=0.40_gIC=0.0500_eS=0.0_/TrainedNetwork'];

        X(i)                    = i;
    end
    
    XAxislabel = 'Fixation Sequence Length (?)';
    %}
    
    %% Trace time constant
    names  = {'0.010', '0.020', '0.030', '0.040', '0.050', '0.060', '0.070', '0.080', '0.090', ... 
              '0.100', '0.200', '0.300', '0.400', '0.500', '0.600', '0.700', '0.800', '0.900', ...
              '1.000', '2.000', '3.000', '4.000', '5.000', '6.000', '7.000', '8.000', '9.000'};
    vals  = [0.010, 0.020, 0.030, 0.040, 0.050, 0.060, 0.070, 0.080, 0.090, ... 
             0.100, 0.200, 0.300, 0.400, 0.500, 0.600, 0.700, 0.800, 0.900, ...
             1.000, 2.000, 3.000, 4.000, 5.000, 6.000, 7.000, 8.000, 9.000];
    
    for i=1:length(vals),
        experiments(i).Folder   = ['hebb/tC=' names{i}  '_/TrainedNetwork']; % tracetimeconstant, tracetimeconstant_short
        X(i)                    = vals(i);
    end
    XAxislabel = 'Trace time constant - \tau_q (s)';
    
    
    %{

    XAxislabel = 'Trace Time Constant - \tau_{q} (s)';
    XTick = [0.01 0.1 1.0 10.0 100.0 900.0]
    %}
    

    %% Plotting
    numExperiments = length(experiments);
    
    % Data
    headCenteredNess = zeros(1,numExperiments);
    rfSizes = zeros(1,numExperiments);
    coverage = zeros(1,numExperiments);
    
    % Iterate experiments and plot
    for e = 1:numExperiments,
        

        % Load analysis file for experiments
        collation = load([expFolder experiments(e).Folder '/analysisResults.mat']);
        res = collation.analysisResults;
        
        % Save data
        headCenteredNess(e) = res.fractionVeryHeadCentered;
        %coverage(e) = collation.analysisResults.uniformityOfVeryHeadCentered
        
        rf = res.RFSize_Linear_Clean(res.headCenteredNess_Linear_Clean >= 0.7);
        rfSizes(e) = mean(rf);
        
    end
    
    figure();
    
    % Plot
    [AX,H1,H2] = plotyy(X, headCenteredNess, X, rfSizes,'semilogx');  %
    
    % Appearance
    hXLabel = xlabel(XAxislabel);
    
    hYLabel1 = get(AX(1),'Ylabel');
    hYLabel2 = get(AX(2),'Ylabel');
    
    set(hYLabel1,'String', 'Head-Centeredness Rate');
    set(hYLabel2,'String', 'Average Receptive Field Size (deg)');

    set(H1,'LineStyle','-','Marker','o','LineWidth',2);
    set(H2,'LineStyle','--','Marker','o','LineWidth',2);
    
    set([AX hXLabel hYLabel1 hYLabel2], 'FontSize', 14);
    
    set(gca,'XGrid','on');
    
    if(exist('XTick')),
        set(AX,'XTick', XTick);
    end
    
end
  
