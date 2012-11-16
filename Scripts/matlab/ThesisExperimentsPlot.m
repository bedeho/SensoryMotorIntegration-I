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
    
    save_filename = 'prewiredPO';

    % Save all experiments to include  
    experiment(1).Name = 'Prewired';
    experiment(1).Folder = expFolder('prewiredPO/X=1_Y=1/TrainedNetwork');
    experiment(2).Name = 'Random';
    experiment(2).Folder = expFolder('prewiredPO/X=1_Y=1/BlankNetwork');
    
    % Setup buffers
    headCenteredNess_X  = [];
    headCenteredNess_Y  = [];
    RFSize = [];

    % Iterate experiments and plot
    for e = 1:length(experiment),

        % Load analysis file for experiments
        data = load([experiment(e).Folder '/analysisResults.mat']);
        
        % Project out data
        headCenteredNess_X{e}  = data.analysisResults.RFLocation_Linear;%;_Clean;
        headCenteredNess_Y{e}  = data.analysisResults.headCenteredNess_Linear;%;_Linear_Clean;
        RFSize{e}              = data.analysisResults.RFSize_Linear;%;_Clean;
        
        
        % Check that we have non-empty dataset
        if(isempty(headCenteredNess_X{e})),
            error(['Empty data set found' experiment(e).Name]);
        end
        
        % Output key numbers
        disp(['Experiment: ' experiment(e).Name]);
        disp(['Fraction discarded due to DISCONTINOUS: ' num2str(data.analysisResults.fractionDiscarded)]);
        disp(['Fraction discarded due to EDGE: ' num2str(data.analysisResults.fractionDiscarded_Edge)]);
        disp(['Fraction discarded due to MULTIPEAK: ' num2str(data.analysisResults.fractionDiscarded_MultiPeak)]);
        disp(['Mean head-centeredness projection: ' num2str(mean(headCenteredNess_Y{e}))]);
        disp(['Entropy (> 0.7): ' num2str(data.analysisResults.uniformityOfVeryHeadCentered)]);
    end
    
    % Put in discarded
    % ...
    
    % lambda/h plot
    % 'XLim', XLim, 'YLim', YLim,
    [maxPlot, miniPlot yProjectionAxis, scatterAxis, xProjectionAxis] = scatterPlotWithMarginalHistograms(headCenteredNess_X, headCenteredNess_Y, 'XTitle', 'Receptive Field Location (deg)', 'YTitle', 'Head-Centeredness', 'Legends', {'Prewired','Random'},'YLabelOffset', 3);
    
    % lambda/psi plot
    [maxPlot, miniPlot yProjectionAxis, scatterAxis, xProjectionAxis] = scatterPlotWithMarginalHistograms(RFSize, headCenteredNess_Y, 'XTitle', 'Receptive Field Size (deg)', 'YTitle', 'Head-Centeredness', 'Legends', {'Prewired','Random'} ,'YLabelOffset', 1);
    
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
