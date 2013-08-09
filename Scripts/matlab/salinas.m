
function salinas()

    % Output neuron prefernce
    h = 0; 

    % Response params
    R_max = 1;
    M = 3;
    sigma = 2;
    
    % Learning parameter
    k = 0;

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

    % Iterate presynaptic neurons in terms of their preferences
    for r=1:length(ret_prefs),
        
        r
        for e=1:length(eye_prefs),
            
            % get prefs
            ret_pref = ret_prefs(r);
            eye_pref = eye_prefs(e);
            
            % BULLSHIT
            % in 2013, use integrand without @
            % in <=2012, use @integrand
            
            % save weight
            slopesign = 1;
            weights_positiveslope(r,e) = dblquad(@integrand,-eye_size,eye_size,-ret_size,ret_size) - k;
            
            slopesign = -1;
            weights_negativeslope(r,e) = dblquad(@integrand,-eye_size,eye_size,-ret_size,ret_size) - k;

        end
    end
    
    figure
    subplot(1,2,1);
    imagesc(weights_negativeslope);
    title('negative slope')
    
    subplot(1,2,2);
    imagesc(weights_positiveslope);
    title('positive slope')

    function total = integrand(eye, ret)
        
        % eye
        gain = slopesign*(eye_pref - eye) + M;
        
        gain(gain < 0) = 0;
        gain(gain > M) = M;
        
        % ret
        gauss = (R_max/M)*exp(-(ret_pref-ret).^2/(2*sigma^2));
        
        % head
        g = exp(-(h - (ret + eye)).^2/(2*sigma^2));

        % total
        total = gauss*(gain.*g);

    end

end