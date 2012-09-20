
function superPlotParameters()

    declareGlobalVars();

    global base;
    
    expName = 'peaked_tracetimeconstant';
    expFolder = [base 'Experiments/' expName '/']; % 'trace_orth_4_small'

    
    experiments(45).Folder =   'ttC=900.00_/TrainedNetwork';
    experiments(44).Folder =   'ttC=800.00_/TrainedNetwork';
    experiments(43).Folder =   'ttC=700.00_/TrainedNetwork';
    experiments(42).Folder =   'ttC=600.00_/TrainedNetwork';
    experiments(41).Folder =   'ttC=500.00_/TrainedNetwork';
    experiments(40).Folder =   'ttC=400.00_/TrainedNetwork';
    experiments(39).Folder =   'ttC=300.00_/TrainedNetwork';
    experiments(38).Folder =   'ttC=200.00_/TrainedNetwork';
    experiments(37).Folder =   'ttC=100.00_/TrainedNetwork';
    
    experiments(36).Folder =   'ttC=90.000_/TrainedNetwork';
    experiments(35).Folder =   'ttC=80.000_/TrainedNetwork';
    experiments(34).Folder =   'ttC=70.000_/TrainedNetwork';
    experiments(33).Folder =   'ttC=60.000_/TrainedNetwork';
    experiments(32).Folder =   'ttC=50.000_/TrainedNetwork';
    experiments(31).Folder =   'ttC=40.000_/TrainedNetwork';
    experiments(30).Folder =   'ttC=30.000_/TrainedNetwork';
    experiments(29).Folder =   'ttC=20.000_/TrainedNetwork';
    experiments(28).Folder =   'ttC=10.000_/TrainedNetwork';
    
    experiments(27).Folder =   'ttC=9.000_/TrainedNetwork';
    experiments(26).Folder =   'ttC=8.000_/TrainedNetwork';
    experiments(25).Folder =   'ttC=7.000_/TrainedNetwork';
    experiments(24).Folder =   'ttC=6.000_/TrainedNetwork';
    experiments(23).Folder =   'ttC=5.000_/TrainedNetwork';
    experiments(22).Folder =   'ttC=4.000_/TrainedNetwork';
    experiments(21).Folder =   'ttC=3.000_/TrainedNetwork';
    experiments(20).Folder =   'ttC=2.000_/TrainedNetwork';
    experiments(19).Folder =   'ttC=1.000_/TrainedNetwork';
    
    experiments(18).Folder =   'ttC=0.900_/TrainedNetwork';
    experiments(17).Folder =   'ttC=0.800_/TrainedNetwork';
    experiments(16).Folder =   'ttC=0.700_/TrainedNetwork';
    experiments(15).Folder =   'ttC=0.600_/TrainedNetwork';
    experiments(14).Folder =   'ttC=0.500_/TrainedNetwork';
    experiments(13).Folder =   'ttC=0.400_/TrainedNetwork';
    experiments(12).Folder =   'ttC=0.300_/TrainedNetwork';
    experiments(11).Folder =   'ttC=0.200_/TrainedNetwork';
    experiments(10).Folder =   'ttC=0.100_/TrainedNetwork';
    
    experiments(9).Folder =    'ttC=0.090_/TrainedNetwork';
    experiments(8).Folder =    'ttC=0.080_/TrainedNetwork';
    experiments(7).Folder =    'ttC=0.070_/TrainedNetwork';
    experiments(6).Folder =    'ttC=0.060_/TrainedNetwork';
    experiments(5).Folder =    'ttC=0.050_/TrainedNetwork';
    experiments(4).Folder =    'ttC=0.040_/TrainedNetwork';
    experiments(3).Folder =    'ttC=0.030_/TrainedNetwork';
    experiments(2).Folder =    'ttC=0.020_/TrainedNetwork';
    experiments(1).Folder =    'ttC=0.010_/TrainedNetwork';

    experiments(45).tick =     900.0;
    experiments(44).tick =     800.0;
    experiments(43).tick =     700.0;
    experiments(42).tick =     600.0;
    experiments(41).tick =     500.0;
    experiments(40).tick =     400.0;
    experiments(39).tick =     300.0;
    experiments(38).tick =     200.0;
    experiments(37).tick =     100.0;
    
    experiments(36).tick =     90.0;
    experiments(35).tick =     80.0;
    experiments(34).tick =     70.0;
    experiments(33).tick =     60.0;
    experiments(32).tick =     50.0;
    experiments(31).tick =     40.0;
    experiments(30).tick =     30.0;
    experiments(29).tick =     20.0;
    experiments(28).tick =     10.0;
    
    experiments(27).tick =     9.0;
    experiments(26).tick =     8.0;
    experiments(25).tick =     7.0;
    experiments(24).tick =     6.0;
    experiments(23).tick =     5.0;
    experiments(22).tick =     4.0;
    experiments(21).tick =     3.0;
    experiments(20).tick =     2.0;
    experiments(19).tick =     1.0;
    
    experiments(18).tick =    0.9;
    experiments(17).tick =    0.8;
    experiments(16).tick =    0.7;
    experiments(15).tick =    0.6;
    experiments(14).tick =    0.5;
    experiments(13).tick =    0.4;
    experiments(12).tick =    0.3;
    experiments(11).tick =    0.2;
    experiments(10).tick =    0.1;
    
    experiments(9).tick =    0.09;
    experiments(8).tick =    0.08;
    experiments(7).tick =    0.07;
    experiments(6).tick =    0.06;
    experiments(5).tick =    0.05;
    experiments(4).tick =    0.04;
    experiments(3).tick =    0.03;
    experiments(2).tick =    0.02;
    experiments(1).tick =    0.01;
    
    

    %{
    experiments(1).Folder =     'L=0.00100_/TrainedNetwork';
    experiments(2).Folder =     'L=0.00200_/TrainedNetwork';
    experiments(3).Folder =     'L=0.00300_/TrainedNetwork';
    experiments(4).Folder =     'L=0.00400_/TrainedNetwork';
    experiments(5).Folder =     'L=0.00500_/TrainedNetwork';
    experiments(6).Folder =     'L=0.00600_/TrainedNetwork';
    experiments(7).Folder =     'L=0.00700_/TrainedNetwork';
    experiments(8).Folder =     'L=0.00800_/TrainedNetwork';
    experiments(9).Folder =     'L=0.00900_/TrainedNetwork';
    
    experiments(10).Folder =    'L=0.01000_/TrainedNetwork';
    experiments(11).Folder =    'L=0.02000_/TrainedNetwork';
    experiments(12).Folder =    'L=0.03000_/TrainedNetwork';
    experiments(13).Folder =    'L=0.04000_/TrainedNetwork';
    experiments(14).Folder =    'L=0.05000_/TrainedNetwork';
    experiments(15).Folder =    'L=0.06000_/TrainedNetwork';
    experiments(16).Folder =    'L=0.07000_/TrainedNetwork';
    experiments(17).Folder =    'L=0.08000_/TrainedNetwork';
    experiments(18).Folder =    'L=0.09000_/TrainedNetwork';

    experiments(19).Folder =    'L=0.10000_/TrainedNetwork';
    experiments(20).Folder =    'L=0.20000_/TrainedNetwork';
    experiments(21).Folder =    'L=0.30000_/TrainedNetwork';
    experiments(22).Folder =    'L=0.40000_/TrainedNetwork';
    experiments(23).Folder =    'L=0.50000_/TrainedNetwork';
    experiments(24).Folder =    'L=0.60000_/TrainedNetwork';
    experiments(25).Folder =    'L=0.70000_/TrainedNetwork';
    experiments(26).Folder =    'L=0.80000_/TrainedNetwork';
    experiments(27).Folder =    'L=0.90000_/TrainedNetwork';

    %experiments(28).Folder =    'L=1.00000_/TrainedNetwork';
    %experiments(29).Folder =    'L=2.00000_/TrainedNetwork';
    %experiments(30).Folder =    'L=3.00000_/TrainedNetwork';
    %experiments(31).Folder =    'L=4.00000_/TrainedNetwork';
    %experiments(32).Folder =    'L=5.00000_/TrainedNetwork';
    %experiments(33).Folder =    'L=6.00000_/TrainedNetwork';
    %experiments(34).Folder =    'L=7.00000_/TrainedNetwork';
    %experiments(35).Folder =    'L=8.00000_/TrainedNetwork';
    %experiments(36).Folder =    'L=9.00000_/TrainedNetwork';
    
    experiments(1).tick =     0.001;
    experiments(2).tick =     0.002;
    experiments(3).tick =     0.003;
    experiments(4).tick =     0.004;
    experiments(5).tick =     0.005;
    experiments(6).tick =     0.006;
    experiments(7).tick =     0.007;
    experiments(8).tick =     0.008;
    experiments(9).tick =     0.009;
    
    experiments(10).tick =    0.010;
    experiments(11).tick =    0.020;
    experiments(12).tick =    0.030;
    experiments(13).tick =    0.040;
    experiments(14).tick =    0.050;
    experiments(15).tick =    0.060;
    experiments(16).tick =    0.070;
    experiments(17).tick =    0.080;
    experiments(18).tick =    0.090;
    
    experiments(19).tick =    0.100;
    experiments(20).tick =    0.200;
    experiments(21).tick =    0.300;
    experiments(22).tick =    0.400;
    experiments(23).tick =    0.500;
    experiments(24).tick =    0.600;
    experiments(25).tick =    0.700;
    experiments(26).tick =    0.800;
    experiments(27).tick =    0.900;
    
    %experiments(28).tick =    1000;
    %experiments(29).tick =    2000;
    %experiments(30).tick =    3000;
    %experiments(31).tick =    4000;
    %experiments(32).tick =    5000;
    %experiments(33).tick =    6000;
    %experiments(34).tick =    7000;
    %experiments(35).tick =    8000;
    %experiments(36).tick =    9000;
    %}
    
    
    %{
    experiments(27).Folder =   'S=0.98_/TrainedNetwork';
    experiments(26).Folder =   'S=0.96_/TrainedNetwork';
    experiments(25).Folder =   'S=0.94_/TrainedNetwork';
    experiments(24).Folder =   'S=0.92_/TrainedNetwork';
    experiments(23).Folder =   'S=0.90_/TrainedNetwork';
    experiments(22).Folder =   'S=0.88_/TrainedNetwork';
    experiments(21).Folder =   'S=0.86_/TrainedNetwork';
    experiments(20).Folder =   'S=0.84_/TrainedNetwork';
    experiments(19).Folder =   'S=0.82_/TrainedNetwork';
    experiments(18).Folder =   'S=0.80_/TrainedNetwork';
    experiments(17).Folder =   'S=0.78_/TrainedNetwork';
    experiments(16).Folder =   'S=0.76_/TrainedNetwork';
    experiments(15).Folder =   'S=0.74_/TrainedNetwork';
    experiments(14).Folder =   'S=0.72_/TrainedNetwork';
    experiments(13).Folder =   'S=0.70_/TrainedNetwork';
    experiments(12).Folder =   'S=0.68_/TrainedNetwork';
    experiments(11).Folder =   'S=0.66_/TrainedNetwork';
    experiments(10).Folder =   'S=0.64_/TrainedNetwork';
    experiments(9).Folder =    'S=0.62_/TrainedNetwork';
    experiments(8).Folder =    'S=0.60_/TrainedNetwork';
    experiments(7).Folder =    'S=0.58_/TrainedNetwork';
    experiments(6).Folder =    'S=0.56_/TrainedNetwork';
    experiments(5).Folder =    'S=0.54_/TrainedNetwork';
    experiments(4).Folder =    'S=0.52_/TrainedNetwork';
    experiments(3).Folder =    'S=0.50_/TrainedNetwork';
    experiments(2).Folder =    'S=0.48_/TrainedNetwork';
    experiments(1).Folder =    'S=0.46_/TrainedNetwork';
    %experiments(8).Folder =    'S=0.44_/TrainedNetwork';
    %experiments(7).Folder =    'S=0.42_/TrainedNetwork';
    %experiments(6).Folder =    'S=0.40_/TrainedNetwork';
    %experiments(5).Folder =    'S=0.38_/TrainedNetwork';
    %experiments(4).Folder =    'S=0.36_/TrainedNetwork';
    %experiments(3).Folder =    'S=0.34_/TrainedNetwork';
    %experiments(2).Folder =    'S=0.32_/TrainedNetwork';
    %experiments(1).Folder =    'S=0.30_/TrainedNetwork';
    
    experiments(27).tick =     98;
    experiments(26).tick =     96;
    experiments(25).tick =     94;
    experiments(24).tick =     92;
    experiments(23).tick =     90;
    
    experiments(22).tick =     88;
    experiments(21).tick =     86;
    experiments(20).tick =     84;
    experiments(19).tick =     82;
    experiments(18).tick =     80;
    
    experiments(17).tick =    78;
    experiments(16).tick =    76;
    experiments(15).tick =    74;
    experiments(14).tick =    72;
    experiments(13).tick =    70;
    
    experiments(12).tick =    68;
    experiments(11).tick =    66;
    experiments(10).tick =    64;
    experiments(9).tick =    62;
    experiments(8).tick =    60;
    
    experiments(7).tick =    58;
    experiments(6).tick =    56;
    experiments(5).tick =    54;
    experiments(4).tick =    52;
    experiments(3).tick =    50;
    
    experiments(2).tick =    48;
    experiments(1).tick =    46;
    %experiments(8).tick =    44;
    %experiments(7).tick =    42;
    %experiments(6).tick =    40;
    
    %experiments(5).tick =    38;
    %experiments(4).tick =    36;
    %experiments(3).tick =    34;
    %experiments(2).tick =    32;
    %experiments(1).tick =    30;
    
    %}
    
    
    
    numExperiments = length(experiments);
    
    % Start figures
    
    linestyle = {'-', '--', ':', '-.'};
    markstyle = {'o', '*', '.','x', 's', 'd'};
    colors = {'r', 'b','k','c', 'm', 'y', 'g', 'w'};
    
    ticks = zeros(1,numExperiments)
    multiUpper = zeros(1,numExperiments);
    multiLower = zeros(1,numExperiments);
    multiMean = zeros(1,numExperiments);
    
    %tickLabels = cell(1,numExperiments);
    %numPerfectCells = zeros(1,numExperiments);
    % Iterate experiments and plot
    for e = 1:numExperiments,
        
        e
        
        % Load analysis file for experiments
        collation = load([expFolder experiments(e).Folder '/collation.mat']);
        
        % Find Number of Perfect cells
        %numPerfectCells(e) = nnz(collation.singleCell(:) > 0.8); % change to multi error bar thing!!
        
        % Save ticks
        ticks(e) = experiments(e).tick;
        
        % Save tick label
        %tickLabels(e) = [num2str(ticks(e)) '']; % add units?
        
        % Error bars
        dist = collation.multiCell;
        multiUpper(e) = dist(3,end) - dist(2,end);
        multiLower(e) = dist(2,end) - dist(1,end);
        multiMean(e) = dist(2,end);
    end
    
    f = figure();
    
    errorbar(ticks,multiMean,multiLower,multiUpper,'LineWidth',2,'MarkerSize',8)
    axis tight
    %errorbarlogx(0.02);
    set(gca,'xscale','log'); 
    
    %plot(ticks,numPerfectCells,'LineWidth',2,'MarkerSize',8);
    
    topValues = multiUpper+multiMean;
    
    axis tight;
    ylim([max(topValues)*-0.01 max(topValues)*1.01]);
    
    grid on
    
        label_y = 'Number of Head-centered Neurons'; % add ERRORBAR ?!
    
    %% Trace time constant
    label_x = 'Trace Time Constant - \tau_{q} (s)';
    ticks = [0.01 0.1 1.0 10.0 100.0 900.0];
    
    
    %% Sparseness
    %label_x = 'Sparseness - \pi (%)';
    
    
    %% Learningrate
    %label_x = 'Learningrate - \rho';
    %ticks = [0.001 0.01 0.1 0.9];
    
    legend('boxoff')
    hTitle = title('')%; title('Varying Sparseness Percentile');
    hXLabel = xlabel(label_x);
    hYLabel = ylabel(label_y);

    set( gca                       , ...
        'FontName'   , 'Helvetica' );
    set([hTitle, hXLabel, hYLabel], ...
        'FontName'   , 'AvantGarde');
    set(gca             , ...
        'FontSize'   , 10           );
    set(hYLabel  , ...
        'FontSize'   , 18          );
    set(hXLabel  , ...
        'FontSize'   , 18          );
    set( hTitle                    , ...
        'FontSize'   , 24          , ...
        'FontWeight' , 'bold'      );
    
    set(gca, ...
      'Box'         , 'on'     , ...
      'TickDir'     , 'in'     , ...
      'TickLength'  , [.02 .02] , ...
      'XMinorTick'  , 'off'      , ...
      'YMinorTick'  , 'off'      , ...
      'LineWidth'   , 2         , ...
      'XTick'       , ticks);
  
  %%
  
     % Make it prettier
     function s = fixLeadingZero(d)

      s = num2str(d);

      if s(1) == '0' && length(s) > 1
          s = s(2:end);
      end

     end
end
  
