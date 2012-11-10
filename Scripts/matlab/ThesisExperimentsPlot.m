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
    global THESIS_FIGURE_PATH;
    
    save_filename = 'test';

    % Save all experiments to include  
    experiment(1).Name = 'Trained';
    experiment(1).Folder = expFolder('base2/L=0.05000_S=0.80_sS=00000001.0_sT=0.000_gIC=0.0500_eS=0.0_/TrainedNetwork');
    experiment(2).Name = 'Untrained';
    experiment(2).Folder = expFolder('base2/L=0.05000_S=0.80_sS=00000001.0_sT=0.000_gIC=0.0500_eS=0.0_/BlankNetwork');
    
    % Setup buffers
    headCenteredNess_X  = [];
    headCenteredNess_Y  = [];
    RFSize = [];

    % Iterate experiments and plot
    for e = 1:length(experiment),

        % Load analysis file for experiments
        data = load([experiment(e).Folder '/analysisResults.mat']);
        
        % Project out data
        headCenteredNess_X{e}  = data.analysisResults.RFLocation_Linear%;_Clean;
        headCenteredNess_Y{e}  = data.analysisResults.headCenteredNess_Linear%;_Linear_Clean;
        RFSize{e}              = data.analysisResults.RFSize_Linear%;_Clean;
        
        % Check that we have non-empty dataset
        if(isempty(headCenteredNess_X{e})),
            error(['Empty data set found' experiment(e).Name]);
        end
        
        % Output key numbers
        %disp(['Experiment: ' experiment(e).Name]);
        %disp(['Fraction discarded due to DISCONTINOUS: ' num2str(analysisResults.fractionDiscarded)]);
        %disp(['Fraction discarded due to EDGE: ' num2str(analysisResults.fractionDiscarded_Edge)]);
        %disp(['Fraction discarded due to MULTIPEAK: ' num2str(analysisResults.fractionDiscarded_MultiPeak)]);
    end
    
    % Put in discarded
    % ...
    
    % lambda/h plot
    % 'XLim', XLim, 'YLim', YLim,
    [maxPlot, miniPlot yProjectionAxis, scatterAxis, xProjectionAxis] = scatterPlotWithMarginalHistograms(headCenteredNess_X, headCenteredNess_Y, 'XTitle', 'Receptive Field Location (deg)', 'YTitle', 'Head-Centeredness (\lambda)', 'Legends', {'Trained','Untrained'});
    
    % lambda/psi plot
    [maxPlot, miniPlot yProjectionAxis, scatterAxis, xProjectionAxis] = scatterPlotWithMarginalHistograms(RFSize, headCenteredNess_Y, 'XTitle', 'Receptive Field Size (deg)', 'YTitle', 'Head-Centeredness (\lambda)');
    
    % SAVE
    %{
    chap = 'chap-2';
    fname = [THESIS_FIGURE_PATH chap '/' save_filename '_retinalconfusion.eps'];
    set(gcf,'renderer','painters');
    print(f,'-depsc2','-painters',fname);
    %}
    
    %}
    
    % Make it prettier
    function s = fixLeadingZero(d)

        s = num2str(d);

        if s(1) == '0' && length(s) > 1
          s = s(2:end);
        end

    end

    function folder = expFolder(name)
        folder = [base 'Experiments/' name];
    end

end
