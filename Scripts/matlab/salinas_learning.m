
function salinas_learning()

    % Output neuron prefernce
    h_prefs = -4:1:4; 

    % Response params
    R_max = 1;
    M = 3;
    sigma = 2;
    
    % Learning parameter
    k = 15;

    % Size of space
    eye_size = 10;
    ret_size = 10;

    % Setup input neuron preferences
    dpref = 1; % preferene resolution in both spaces
    eye_prefs = -eye_size:dpref:eye_size;
    ret_prefs = fliplr(-ret_size:dpref:ret_size);

    % Seight vectors of output neuron,
    weights_positiveslope = zeros(length(ret_prefs), length(eye_prefs));
    weights_negativeslope = zeros(length(ret_prefs), length(eye_prefs));
    
    % Training stimuli
    training_ret = -6.5:1:6.5;
    training_eye = -6.5:1:6.5;
    numTrainingInputs = length(training_ret)*length(training_eye);
    
    % Computing mesh used to evaluate input layer
    [eye_mesh ret_mesh] = meshgrid(eye_prefs,ret_prefs);
    
    % Iterate all combinations of ret,eye locations to train: could have
    % vectorized, but what the heck
    for r=1:length(training_ret),
        
        r
        for e=1:length(training_eye),
            
            % Get stimuli
            ret = training_ret(r);
            eye = training_eye(e);
            
            % Sensory layer response
            total_positive = sensory_layer_response(eye, ret, 1);
            total_negative = sensory_layer_response(eye, ret, -1);
            
            % Motor layer response
            g = exp(-(h_prefs - (ret + eye)).^2/(2*sigma^2));
            
            



                % save weight
                slopesign = 1;
                weights_positiveslope(r,e) = dblquad(@integrand,-eye_size,eye_size,-ret_size,ret_size);

                slopesign = -1;
                weights_negativeslope(r,e) = dblquad(@integrand,-eye_size,eye_size,-ret_size,ret_size);

        end
    end
    
    figure
    subplot(1,2,1);
    imagesc(weights_negativeslope);
    title('negative slope')
    
    subplot(1,2,2);
    imagesc(weights_positiveslope);
    title('positive slope')
    
    
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