
function salinas_learning()

    % Output neuron prefernce
    h = 0; %-4:1:4; 

    % Response params
    R_max = 1;
    M = 3;
    sigma = 100;
    
    % Learning parameter
    k = 15;
    
    % Training stimuli
    training_ret = -6.5:1:6.5;
    training_eye = -6.5:1:6.5;
    numTrainingInputs = length(training_ret)*length(training_eye);

    % Size of space
    eye_size = 40;
    ret_size = 40;

    % Setup input neuron preferences
    eye_prefs = -eye_size:1:eye_size;
    ret_prefs = fliplr(-ret_size:1:ret_size);
    
    % Response history
    input_positiveslope_history = zeros(length(ret_prefs), length(eye_prefs), numTrainingInputs);
    input_negativeslope_history = zeros(length(ret_prefs), length(eye_prefs), numTrainingInputs);
    output_history = zeros(numTrainingInputs,1);
    
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
            g = exp(-(h - (ret + eye)).^2/(2*sigma^2));
            
            % Save data
            input_positiveslope_history(:, :, n) = total_positive;
            input_negativeslope_history(:, :, n) = total_negative;
            output_history(n) = g;
            
            % Increment training nr counter
            n = n + 1;
        end
    end
    
    
    
    %% Make weights
    
    % Seight vectors of output neuron
    weights_positiveslope = zeros(length(ret_prefs), length(eye_prefs));
    weights_negativeslope = zeros(length(ret_prefs), length(eye_prefs));
    
    for r=1:length(ret_prefs), % could have vectorized, but why bother, need to finish quick!
        
        for e=1:length(eye_prefs),
            
            weights_positiveslope(r,e) = mean(squeeze(input_positiveslope_history(r, e, :)) .* output_history) - k;
            weights_negativeslope(r,e) = mean(squeeze(input_negativeslope_history(r, e, :)) .* output_history) - k;
        
        end
    end
    
    %% Show figure
    figure
    subplot(1,2,1);
    surf(weights_negativeslope);
    title('negative slope')
    
    subplot(1,2,2);
    surf(weights_positiveslope);
    title('positive slope')
    
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