
function prewiredModel(filename)

    % Open file
    fileID = fopen(filename,'w+');
    
    % Init variables
    dimensions = OneD_DG_Dimensions();
    
    numRegions = 2;
    targets = dimensions.targets;
    numTargets = length(targets);

    % Write number of regions
    fwrite(fileID, numRegions, 'uint16');
    
    % Write 7a dimensions, dummy info really
    fwrite(fileID, [1 1 1], 'uint16');
    
    % Layer 1
    verticalDimension = 8;
    horizontalDimension = 8;
    depth = 1;
    %fanInCount = 1000;
    
    % Write LIP dimensions, dummy info really
    fwrite(fileID, [verticalDimension horizontalDimension depth], 'uint16');
    
    % Allocate space to keep network,
    % online generation is not possible since there is a header,
    % numberOfAFferentSynapses varies across neurons
    synapseBuffer = cell(verticalDimension,horizontalDimension);
    
    coeff = 0.3;
    activeNeurons = coeff*(verticalDimension * horizontalDimension);
    
    % Write neuron spesific specs
    for col=1:verticalDimension,
        
     disp([num2str(col*100/verticalDimension) '%']);
        
      for row=1:horizontalDimension,

            % Pick target
            target = targets(randi(numTargets,1,1));
            
            % Setup neuron variables
            numberOfAfferentSynapses = 0;
            
            % Connect
            for d=1:2,
                for eye=1:dimensions.nrOfEyePositionPrefrerence,
                    for ret=1:dimensions.nrOfVisualPreferences,
                        
                        eyePref = dimensions.eyePositionPreferences(eye);
                        retPref = dimensions.visualPreferences(ret);
                        
                        if rand([1 1]) > 0.9 && ((eyePref+retPref <= target && d==1) || (eyePref+retPref >= target && d==2)),
                            
                            % Increase number of synapses
                            numberOfAfferentSynapses = numberOfAfferentSynapses + 1;
                            
                            % Get random weight
                            weight = rand([1 1]);
                            
                            % Save synapse
                            synapses(:,numberOfAfferentSynapses) = [1 d ret eye weight];
                        end
                    end
                end
            end
            
            % Normalize weight vector
            synapses(5,:) = synapses(5,:)/norm(synapses(5,:));
            
            % Save synapses
            synapseBuffer{col,row} = synapses;
            
            % Write out for header
            fwrite(fileID, numberOfAfferentSynapses, 'uint16');
        end
    end
    
   % Synapse i:
   % synapses(1,i) = regionNr
   % synapses(2,i) = depth
   % synapses(3,i) = row
   % synapses(4,i) = col
   % synapses(5,i) = weight
    
    % Write out actual network
    for col=1:verticalDimension,
        for row=1:horizontalDimension,
            
            % Get synapses
            synapses = synapseBuffer{col,row};
            
            % Iterate afferent synapses and dump
            for s=1:length(synapses),
                
               % Write synapse
               fwrite(fileID, synapses(1:4,s), 'uint16'); 
               fwrite(fileID, synapses(5,s), 'float32'); 
            end
        end
    end
    
    fclose(fileID);

end

