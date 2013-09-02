%
%  zipser.m
%  SMI
%
%  Created by Bedeho Mender on 26/10/12.
%  Copyright 2012 OFTNAI. All rights reserved.
%

function zipser()

    % D. Zipser & R. Andersen (1988)
    
    % Seed rng
    rng(33, 'twister');
    
    % Input:
    % retinal: 8x8=64 gaussian retinal units, sigma = 15 deg, spacing = 10 deg
    % eye position: (2 y slope signs) x (2 x slope signs) x (8 intercepts) = 32
    retinalSigma = 15;
    retinalPreferencesX = centerN3(10,8);
    retinalPreferencesY = centerN3(10,8);
    [retinalMeshX, retinalMeshY] = meshgrid(retinalPreferencesX, retinalPreferencesY);
    eyePositionSlopes = [rand(1,8) (-1*rand(1,8))];
    eyePositionIntercepts = 2*rand(1,16) - 1;
    numInputNeurons = 8*8+8*4; % 96
    
    % Hidden units: 9-36 units
    numHiddenNeurons = 9;
    
    % Output units:
    % Head centered units: same as retinal, just head centered
    outputSigma = 18;
    headPreferencesX = centerN3(10,8);
    headPreferencesY = centerN3(10,8);
    [headMeshX, headMeshY] = meshgrid(headPreferencesX, headPreferencesY);
    numOutputNeurons = numel(headMeshX);
    
    % Stimuli:
    % 441=21*21 pairs of retinal and eye positions.
    % 21 retinal locations in [-40,40]
    % 21 eye positions in [-20,20]
    
    %{
    retinalTargetsX = centerN(80, 21);
    retinalTargetsY = centerN(80, 21);
    eyeTargetsX = centerN(40, 21);
    eyeTargetsY = centerN(40, 21);
    %numPatterns = length(retinalTargetsX)*length(retinalTargetsY)*length(eyeTargetsX)*length(eyeTargetsY);
    %}
    
    retinalTargetsX = centerN(80, 4);
    retinalTargetsY = centerN(80, 4);
    eyeTargetsX = centerN(40, 3);
    eyeTargetsY = centerN(40, 3);
    
    % Network Parameters
    learningrate = 0.001;
    numEpochs = 30;
    
    [inputPatterns, outputPatterns] = generatePatterns();
    
    % Create network
    untrainedNet = feedforwardnet([numHiddenNeurons]);
    
    % Setup Training
    untrainedNet.trainParam.epochs = numEpochs;
    untrainedNet.trainParam.goal = 0.01;
    untrainedNet.trainParam.lr = learningrate;
    untrainedNet.trainParam.show = 1;
    untrainedNet.trainParam.time = 1000;
    
    % Train
    [trainedNet, tr] = train(untrainedNet, inputPatterns, outputPatterns);
    
    %% Analyze weight distribution
    figure;
    hLayer = trainedNet.LW{2,1};
    iLayer = trainedNet.IW{1};
    
    ticks = -3:0.1:3;
    
    hdist = hist(hLayer(:)', ticks);
    idist = hist(iLayer(:)', ticks);
    
    hBar = bar(ticks,[hdist' idist'],'stacked','LineStyle','none');
    FaceColors = {[67,82,163]/255; [238,48,44]/255};
    for i=1:length(hBar),
        set(hBar(i),'FaceColor', FaceColors{i}); %, {'EdgeColor'}, edgeColors
    end
    
    xlim([-3 3]);
    
    hXLabel = xlabel('Synaptic Weight');
    hYLabel = ylabel('Number of Synapses');
    hLegend = legend('Hidden Layer Unit','Input Layer Unit');

    set([hYLabel hXLabel], 'FontSize', 16);
    set(gca, 'FontSize', 14);
    box off
    axis square
    
    %% Hidden-> output weight matrix
    figure;
    imagesc(trainedNet.LW{2,1}');
    
    hXLabel = xlabel('Output Layer Unit');
    hYLabel = ylabel('Hidden Layer Unit');

    set([hYLabel hXLabel], 'FontSize', 16);
    set(gca, 'FontSize', 14);
    colorbar
    axis square
    
    %% Show Input->Hidden Weight matrix
    figure;
    imagesc(trainedNet.IW{1}');
    
    hXLabel = xlabel('Hidden Layer Unit');
    hYLabel = ylabel('Input Layer Unit');

    set([hYLabel hXLabel], 'FontSize', 16);
    set(gca, 'FontSize', 14);
    colorbar
    axis square
    
    %% DALE principle
    %{
    % OLD STYLE
    figure();
    iMoreExcitatory = sum(trainedNet.IW{1} >= 0) - sum(trainedNet.IW{1} < 0); % 9x96
    hMoreExcitatory = sum(trainedNet.LW{1} >= 0) - sum(trainedNet.LW{1} < 0); % 
    hist([iMoreExcitatory hMoreExcitatory],-9:1:9);
    xlim([-9 9]);
    
    hXLabel = xlabel('Number of Surplus Excitatory Projections');
    hYLabel = ylabel('Number of Neurons');
    
    set([hYLabel hXLabel], 'FontSize', 16);
    set(gca, 'FontSize', 14);
    
    box off
    %}
    % NEW STYLE
    figure();
    
    %hidden layer units
    hiddenToOutput_numExcitatory = sum(trainedNet.LW{2,1} > 0);
    hiddenToOutput_numInhibitory = sum(trainedNet.LW{2,1} < 0);
    
    inputToHidden_numExcitatory = sum((trainedNet.IW{1} > 0));
    inputToHidden_numInhibitory = sum((trainedNet.IW{1} < 0));
    
    [receptivefieldPlot, yProjectionAxis, scatterAxis, xProjectionAxis, XLim, YLim] = scatterPlotWithMarginalHistograms({hiddenToOutput_numExcitatory; inputToHidden_numExcitatory}, {hiddenToOutput_numInhibitory; inputToHidden_numInhibitory}, 'XTitle', 'Excitatory Efferents', 'YTitle', 'Inhibitory Efferents', 'FaceColors', FaceColors, 'Legends', {'Hidden Layer'; 'Input Layer'},'Location', 'SouthEast');
    
    % Generate stimuli
    function [inputPatterns, outputPatterns] = generatePatterns()

        %inputPatterns = zeros(numInputNeurons, numPatterns);
        %outputPatterns = zeros(numOutputNeurons, numPatterns);
        
        % Iterate all targets comboes
        counter = 1;
        
        %numRetinalTargets = 20;
        
        %while numRetinalTargets > 0,
            
            %rX = retinalTargetsX(randi(numel(retinalTargetsX),1,1));
            %rY = retinalTargetsY(randi(numel(retinalTargetsX),1,1)); 
            
            %rX=retinalTargetsX(1)
            for rX=retinalTargetsX,
                for rY=retinalTargetsY,
                %rY=retinalTargetsY(1)
                    for eX=eyeTargetsX,
                        %eY=eyeTargetsY(1);
                        for eY=eyeTargetsY,

                            % Input pattern
                            ret = exp(-((rX - retinalMeshX).^2 + (rY - retinalMeshY).^2)/(2*retinalSigma^2));
                            eyeX = eyePositionSlopes*eX + eyePositionIntercepts;
                            eyeY = eyePositionSlopes*eY + eyePositionIntercepts;

                            in = [ret(:)' eyeX(:)' eyeY(:)'];

                            inputPatterns(:,counter) = in;

                            % Output pattern
                            hX = rX+eX;
                            hY = rY+eY;

                            out = exp(-((hX - headMeshX).^2 + (hY - headMeshY).^2)/(2*outputSigma^2));

                            outputPatterns(:,counter) = out(:);

                            counter = counter + 1;

                        end
                    end
                end
            end
            
            %numRetinalTargets = numRetinalTargets - 1;
            
        %end

    end

end