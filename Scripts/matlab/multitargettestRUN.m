
%  Workflow for multi target testing:
%
%  1) Generate classic and multi test stimuli
%
%  2) Run classic experiment with testing and training on normal stimuli
%
%  3) Create a new experiment folder "multitargettest" manually, put
%  "TrainedNetwork.txt" and "Parameters.txt" in the folder
%
%  4) Run this script

% input
% MTT_peakedgain_trained
% MTT_global
% MTT_multitarget_trained
% MTT_peakedgain_trained_lowsparsity60
% *****not done: MTT_peakedgain_untrained

experiments = {'MTT_peakedgain_trained', 'MTT_global', 'MTT_multitarget_trained', 'MTT_peakedgain_trained_lowsparsity60'};

stim = 'dist_1_mulitargettest_1-visualfield=200.00-eyepositionfield=60.00-fixations=240.00-targets=1.00-fixduration=0.30-fixationsequence=30.00-seed=72.00-samplingrate=100.00-multiTest';

% temp vars
dphilFolder = '/Network/Servers/mac0.cns.ox.ac.uk/Volumes/Data/Users/mender/Dphil/Projects/SensoryMotorIntegration-I/';
stimuli = [dphilFolder 'Stimuli/' stim '/data.dat'];

for i=length(experiments),
    
    exp = experiments{i};
    
    % Run experiment
    disp('Testing...');
    system([dphilFolder 'Source/DerivedData/SMI/Build/Products/Release/SMI ' ...
            'test ' ...
            dphilFolder 'Experiments/' exp '/Parameters.txt ' ...
            dphilFolder 'Experiments/' exp '/TrainedNetwork.txt ' ... 
            stimuli ' ' ...
            dphilFolder 'Experiments/' exp '/ ']);

    % Analysis
    disp('Analysis...');
    NEWMultiTargetTestingAnalysis(stim, [dphilFolder 'Experiments/' exp]);

end