%
%  OneD_Stimuli_MovementDynamicsFigure.m
%  SMI
%
%  Created by Bedeho Mender on 06/11/12.
%  Copyright 2012 OFTNAI. All rights reserved.
%

function OneD_Stimuli_MovementDynamicsFigure(stimuli)

    % Import global variables
    declareGlobalVars();
    
    global base;

    % Make figure
    fig = figure();

    % Load file
    [samplingRate, numberOfSimultanousObjects, visualFieldSize, eyePositionFieldSize, buffer] = OneD_Stimuli_Load(stimuli);

    timeStep = (1/samplingRate);

    % Parse out each object
    [objects, minSequenceLength, objectsFound] = OneD_Stimuli_Parse(buffer);

    % Plot movement dynamics of each object
    totalTimePerObject = (minSequenceLength-1) * timeStep;

    % Plot
    for o = 1:objectsFound,

        tmp = objects{o};
        yvals = tmp(:,1);
        ticks = (0:(length(yvals)-1)) * timeStep;

        % color
        %c = mod(o-1,length(linestyle)) + 1;

        plot(ticks, yvals , '-','LineWidth',1,'Color','b');

        hold on;
    end

    axis([0 totalTimePerObject -eyePositionFieldSize/2 eyePositionFieldSize/2]);
    hYLabel = ylabel('Eye Position (deg)');
    hXLabel = xlabel('Times (s)');
    set([hYLabel hXLabel gca], 'FontSize', 16);
    
    % Save
    fname = [base 'Stimuli/' stimuli '/' stimuli '.eps'];
    set(gcf,'renderer','painters');
    print(fig,'-depsc2','-painters',fname);

end