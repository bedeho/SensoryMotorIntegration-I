
function salinas_learning()

    % Output neuron prefernce
    h_prefs = -4:1:4;
    numOutputUnits = length(h_prefs);

    % Response params
    R_max = 1;
    M = 3;
    sigma = 3;
    
    % Learning parameter
    k = 0;
    
    % Training stimuli
    training_ret = -6.5:1:6.5;
    training_eye = -6.5:1:6.5;
    numTrainingInputs = length(training_ret)*length(training_eye);

    % Size of space
    eye_size = 10;
    ret_size = 10;

    % Setup input neuron preferences
    pref_dist = 0.5;
    eye_prefs = -eye_size:pref_dist:eye_size;
    ret_prefs = fliplr(-ret_size:pref_dist:ret_size);
    
    % Response history
    input_positiveslope_history = zeros(length(ret_prefs), length(eye_prefs), numTrainingInputs);
    input_negativeslope_history = zeros(length(ret_prefs), length(eye_prefs), numTrainingInputs);
    output_history = zeros(numTrainingInputs, numOutputUnits);
    
    % Computing mesh used to evaluate input layer
    [eye_mesh ret_mesh] = meshgrid(eye_prefs, ret_prefs);
    
    %% Compute input and output responses
    % Iterate all combinations of ret,eye locations to train: could have
    % vectorized, but what the heck
    n = 1;
    for r=1:length(training_ret),
        
        for e=1:length(training_eye),
            
            % Get stimuli
            ret = training_ret(r);
            eye = training_eye(e);
            
            % Sensory layer response
            total_positive = sensory_layer_response(eye, ret, 1);
            total_negative = sensory_layer_response(eye, ret, -1);
            
            % Motor layer response
            g = exp(-(h_prefs - (ret + eye)).^2/(2*sigma^2));
            
            % Save data
            input_positiveslope_history(:, :, n) = total_positive;
            input_negativeslope_history(:, :, n) = total_negative;
            output_history(n,:) = g;
            
            % Increment training nr counter
            n = n + 1;
        end
    end
    
    %% Make weights
    
    % Seight vectors of output neuron
    weights_positiveslope = zeros(length(ret_prefs), length(eye_prefs), numOutputUnits);
    weights_negativeslope = zeros(length(ret_prefs), length(eye_prefs), numOutputUnits);
    
    for r=1:length(ret_prefs), % could have vectorized, but why bother, need to finish quick!
        for e=1:length(eye_prefs),
            for h =1:numOutputUnits,
                weights_positiveslope(r,e,h) = mean(squeeze(input_positiveslope_history(r, e, :)) .* output_history(:,h)) - k;
                weights_negativeslope(r,e,h) = mean(squeeze(input_negativeslope_history(r, e, :)) .* output_history(:,h)) - k;
            end
        end
    end
    
    %% Show Weights of neuron 1
    showPrettyWeightVector(weights_negativeslope(:,:,1));
    showPrettyWeightVector(weights_positiveslope(:,:,1));
    
    %% Analyze weight distribution
    figure;

    data = [weights_positiveslope(:)' weights_negativeslope(:)'];
    max_deviation = max(data);
    min_deviation = min(data);
    ticks = min_deviation:(max_deviation-min_deviation)/100:max_deviation;
    
    hdist = hist(data, ticks);

    hBar = bar(ticks,hdist','stacked','LineStyle','none');
    set(hBar(1),'FaceColor', [67,82,163]/255); %, {'EdgeColor'}, edgeColors

    xlim([min_deviation max_deviation]);
    
    hXLabel = xlabel('Synaptic Weight');
    hYLabel = ylabel('Number of Synapses');

    set([hYLabel hXLabel], 'FontSize', 16);
    set(gca, 'FontSize', 14);
    box off
    
    axis square
    
    %% weight vector display 
    function showPrettyWeightVector(w)
        
        figure
        imagesc(w);
        hXLabel = xlabel('Eye Position - y');
        hYLabel = ylabel('Retinal Location - x');
        set([hYLabel hXLabel], 'FontSize', 16);

        set(gca, 'FontSize', 14);
        axis square;
        
        % axis ticks
        dist = 2/pref_dist;
        
        % x axis ticks
        eyeTicks = 1:length(eye_prefs);
        eyeTicks = eyeTicks(1:dist:end);
        eyeLabels = eye_prefs(1:dist:end);
        eyeCellLabels = cell(1,length(eyeLabels));
        for l=1:length(eyeLabels),
          eyeCellLabels{l} = [num2str(eyeLabels(l))];
        end
        
        set(gca,'XTick', eyeTicks);
        set(gca,'XTickLabel', eyeCellLabels);
        
        % y axis
        retTicks = 1:length(ret_prefs);
        retTicks = retTicks(1:dist:end);
        retLabels = ret_prefs(1:dist:end);
        retCellLabels = cell(1,length(retLabels));
        for l=1:length(retLabels),
          retCellLabels{l} = [num2str(retLabels(l))];
        end

        set(gca,'YTick', retTicks);
        set(gca,'YTickLabel',retCellLabels);
        
    end


    
    %% Evaluate input layer
    function f = sensory_layer_response(eye, ret, slopesign)
        
        % eye
        gain = slopesign*(eye_mesh - eye) + M; % abs
        
        gain(gain < 0) = 0;
        gain(gain > M) = M;
        
        % ret
        gauss = (R_max/M)*exp(-(ret_mesh-ret).^2/(2*sigma^2));
        
        % f
        f = gauss.*gain;

    end

end