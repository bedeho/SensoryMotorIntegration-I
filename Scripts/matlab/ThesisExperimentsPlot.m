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
    
    %{ 
    % Peaked gain
    experiment(1).Name = 'Prewired';
    experiment(1).Folder = expFolder('prewiredPO/X=1_Y=1/TrainedNetwork');
    experiment(2).Name = 'Random';
    experiment(2).Folder = expFolder('prewiredPO/X=1_Y=1/BlankNetwork');
    %}
    
    experiment(1).Name = 'Prewired';
    experiment(1).Folder = expFolder('prewiredPO/X=1_Y=1/TrainedNetwork');
    experiment(2).Name = 'Random';
    experiment(2).Folder = expFolder('prewiredPO/X=1_Y=1/BlankNetwork');
    
    % Setup buffers
    numExperiments = length(experiment);
    
    RFLocation  = cell(1,numExperiments);
    headCenteredNess  = cell(1,numExperiments);
    RFSize = cell(1,numExperiments);

    % Iterate experiments and plot
    for e = 1:numExperiments,

        % Load analysis file for experiments
        data = load([experiment(e).Folder '/analysisResults.mat']);
        
        % Project out data
        RFLocation{e} = data.analysisResults.RFLocation_Linear;
        headCenteredNess{e} = data.analysisResults.headCenteredNess_Linear;
        RFSize{e} = data.analysisResults.RFSize_Linear;
        
        RFLocation_Clean{e} = data.analysisResults.RFLocation_Linear_Clean;
        headCenteredNess_Clean{e} = data.analysisResults.headCenteredNess_Linear_Clean;
        RFSize_Clean{e} = data.analysisResults.RFSize_Linear_Clean;
        
        % Check that we have non-empty dataset
        if(isempty(headCenteredNess{e})),
            error(['Empty data set found' experiment(e).Name]);
        end
        
        % Output key numbers
        disp(['Experiment: ' experiment(e).Name]);
        disp(['Fraction discarded due to DISCONTINOUS: ' num2str(data.analysisResults.fractionDiscarded)]);
        disp(['Fraction discarded due to EDGE: ' num2str(data.analysisResults.fractionDiscarded_Edge)]);
        disp(['Fraction discarded due to MULTIPEAK: ' num2str(data.analysisResults.fractionDiscarded_MultiPeak)]);
        disp(['Entropy (> 0.7): ' num2str(data.analysisResults.uniformityOfVeryHeadCentered)]);
        
        disp(['Mean RF-Location: ' num2str(mean(RFLocation_Clean{e}))]);
        disp(['Mean Head-centeredness: ' num2str(mean(headCenteredNess_Clean{e}))]);
        disp(['Mean RFSize projection: ' num2str(mean(RFSize_Clean{e}))]);
        
        disp(['***']);
    end
    
    % Put in discarded
    % ...
    
    % lambda/h plot
    % 'XLim', XLim, 'YLim', YLim,
    [maxPlot, miniPlot yProjectionAxis, scatterAxis, xProjectionAxis] = scatterPlotWithMarginalHistograms(RFLocation, headCenteredNess, 'XTitle', 'Receptive Field Location (deg)', 'YTitle', 'Head-Centeredness', 'Legends', {'Prewired','Random'},'YLabelOffset', 3);
    
    % lambda/psi plot
    [maxPlot, miniPlot yProjectionAxis, scatterAxis, xProjectionAxis] = scatterPlotWithMarginalHistograms(RFSize, headCenteredNess, 'XTitle', 'Receptive Field Size (deg)', 'YTitle', 'Head-Centeredness', 'Legends', {'Prewired','Random'} ,'YLabelOffset', 1);
    
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
