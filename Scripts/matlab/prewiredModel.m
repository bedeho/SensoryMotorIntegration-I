
function prewiredModel(filename)

    % Stimuli/Model Parameters
    q                                   = 0.8; % targetRangeProportionOfVisualField
    visualFieldSize                     = 200; % Entire visual field (rougly 100 per eye), (deg)
    eyePositionFieldSize                = (1-q)*visualFieldSize; % (1-q)*visualFieldSize OR equivalently (visualFieldSize/2 - targetVisualRange/2)
    targetVisualRange                   = visualFieldSize * q;
    targetEyePositionRange              = 0.8*eyePositionFieldSize; %eyePositionFieldSize;
    visualPreferenceDistance            = 1;
    eyePositionPrefrerenceDistance      = 1;
    numTargetPositions                  = 5;
    
    % Setup random number generator
    seed = 3;
    rng(seed, 'twister');
    
    % Init variables
    visualPreferences                   = centerDistance(visualFieldSize, visualPreferenceDistance);
    eyePositionPreferences              = centerDistance(eyePositionFieldSize, eyePositionPrefrerenceDistance);
    nrOfVisualPreferences               = length(visualPreferences);
    nrOfEyePositionPrefrerence          = length(eyePositionPreferences);
    targets                             =  centerN(targetVisualRange, numTargetPositions);
   
    % Output layer
    numRegions = 2;
    dim = 30;
    verticalDimension = dim;
    horizontalDimension = dim;
    
    % Allocate space to keep network,
    % online generation is not possible since there is a header,
    % numberOfAFferentSynapses varies across neurons
    synapseBuffer = cell(verticalDimension,horizontalDimension);
    
    coeff = 0.3;
    activeNeurons = coeff*(verticalDimension * horizontalDimension);
    
    % Write neuron spesific specs
    for row=1:verticalDimension,
        
        disp([num2str(row*100/verticalDimension) '%']);
        
        for col=1:horizontalDimension,

            % Pick target
            target = targets(randi(numTargets,1,1));
            
            % Setup neuron variables
            numberOfAfferentSynapses = 0;
            
            % Generated figure
            %{
            figure();
            title(['Row,Col =' num2str(row) ',' num2str(col)])
            mat1 = zeros(dimensions.nrOfVisualPreferences,dimensions.nrOfEyePositionPrefrerence);
            mat2 = zeros(dimensions.nrOfVisualPreferences,dimensions.nrOfEyePositionPrefrerence);
            %}
            
            % FORGOT TO CLEAR <== damn this bug
            clearvars synapses
            
            % Connect
            for d=1:2,
                for ret=1:nrOfVisualPreferences,
                    
                    retPref = visualPreferences(nrOfVisualPreferences - (ret - 1));
                    
                    for eye=1:nrOfEyePositionPrefrerence,
                    
                        eyePref = eyePositionPreferences(eye);
                                                
                        if rand([1 1]) > 0.9 && ((eyePref+retPref <= target && d==1) || (eyePref+retPref >= target && d==2)),
                        %if eye == col,    
                            % Increase number of synapses
                            numberOfAfferentSynapses = numberOfAfferentSynapses + 1;
                            
                            % Get random weight
                            weight = rand([1 1]);
                            
                            % Save synapse
                            synapses(:,numberOfAfferentSynapses) = [0 (d-1) (ret-1) (eye-1) weight];
                            
                            %{
                            % FIGURE
                            if d==1,
                                mat1(ret,eye) = mat1(ret,eye) + weight;
                            else
                                mat2(ret,eye) = mat2(ret,eye) + weight;
                            end
                            %}
                            
                        end
                        
                    end
                end
            end
            
            
            % FIGURE
            %{
                subplot(1,2,1);
                imagesc(mat1);
                colorbar
                subplot(1,2,2);
                imagesc(mat2);
                colorbar
            %}
            
            % Normalize weight vector
            %synapses(5,:) = synapses(5,:)/norm(synapses(5,:));
            
            % Save synapses
            synapseBuffer{row,col} = synapses;
            
            % Write out for header
            fwrite(fileID, numberOfAfferentSynapses, 'uint16');
            
            % Output neuron
            %disp(['Row,Col =' num2str(row) ',' num2str(col) ': ' num2str(numberOfAfferentSynapses)])
            
        end
    end
    
    % Synapse i:
    % synapses(1,i) = regionNr
    % synapses(2,i) = depth
    % synapses(3,i) = row
    % synapses(4,i) = col
    % synapses(5,i) = weight
   
    % Open file
    fileID = fopen(filename,'w+');

    % Write number of regions
    fwrite(fileID, numRegions, 'uint16');
    
    % Write 7a dimensions, dummy info really
    fwrite(fileID, [nrOfVisualPreferences nrOfEyePositionPrefrerence 2], 'uint16');
    
    % Write LIP dimensions, dummy info really
    fwrite(fileID, [verticalDimension horizontalDimension 1], 'uint16');
    
    % Write out actual network
    for row=1:verticalDimension,
        for col=1:horizontalDimension,
            
            % Get synapses
            afferents = synapseBuffer{row,col};
            
            % Iterate afferent synapses and dump
            for s=1:length(afferents),
                
               % afferents(:,s)
                
               % Write synapse
               fwrite(fileID, afferents(1:4,s), 'uint16');
               fwrite(fileID, afferents(5,s), 'float32');
            end
        end
    end
    
    fclose(fileID);

end

