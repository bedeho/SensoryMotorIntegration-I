
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
    eye_size = 4;
    ret_size = 4;

    % Resolutoins
    dpref = 1; % preferene resolution in both spaces

    % Setup preferences
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
            weights_positiveslope(r,e) = dblquad(@integrand,-eye_size,eye_size,-ret_size,ret_size);
            
            slopesign = -1;
            weights_negativeslope(r,e) = dblquad(@integrand,-eye_size,eye_size,-ret_size,ret_size);

        end
    end

    function total = integrand(eye, ret)
        
        % eye
        gain = slopesign*abs(eye_pref - eye) + M;
        
        gain(gain < 0) = 0;
        gain(gain > M) = M;
        
        % ret
        gauss = (R_max/M)*exp(-(ret_pref-ret).^2/(2*sigma^2));
        
        % head
        g = exp(-(h - (ret + eye)).^2/(2*sigma^2));

        % total
        total = gauss*(gain.*g);

    end

    imagesc(weights_positiveslope);

    %{


    % Output neuron prefernce
    h = 0; 

    % Response params
    R_max = 1;
    M = 3;
    sigma = 2;

    % Size of space
    eye_size = 10;
    ret_size = 10;

    % Resolutoins
    dpref = 1; % preferene resolution in both spaces
    dstep = 0.1; % integration step size

    % Setup preferences
    eye_prefs = -eye_size:dpref:eye_size;
    ret_prefs = -ret_size:dpref:ret_size;

    % Seight vectors of output neuron,
    weights_positiveslope = zeros(length(ret_prefs), length(eye_prefs));
    weights_negativeslope = zeros(length(ret_prefs), length(eye_prefs));

    % Setup mesh for evalutation response
    [eye_mesh ret_mesh] = meshgrid(-ret_size:dstep:ret_size, -eye_size:dstep:eye_size);
    head_mesh = eye_mesh+ret_mesh;

    % flip mesh??

    % Iterate presynaptic neurons in terms of their preferences
    for ret_pref=ret_prefs,
        for eye_pref=eye_prefs,

            % Eye components
            positive_slope = abs(eye_pref - eye_mesh) + M;
            negative_slope = -abs(eye_pref - eye_mesh) + M;

            positive_slope(positive_slope < 0) = 0;
            negative_slope(negative_slope < 0) = 0;

            positive_slope(positive_slope > M) = M;
            negative_slope(negative_slope > M) = M;

            % Retinal components
            ret = (R_max/M)*exp(-(ret_pref-ret_mesh).^2/(2*sigma^2));

            % g - output
            g = exp(-(head_mesh - h).^2/(2*sigma^2));

            % f - input
            f_positive = ret.*positive_slope;
            f_negative = ret.*negative_slope;

            % integrate
            total_positive = g.*f_positive;
            total_negative = g.*f_negative;



            % save weight
            weights_positiveslope =
            weights_negativeslope =


        end
    end

    %}

end