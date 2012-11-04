%
%  vararginProcessing.m
%  SMI
%
%  Created by Bedeho Mender on 04/11/12.
%  Copyright 2012 OFTNAI. All rights reserved.
%
%  variableArguments: varargin that must be processed
%  knownArgumentNames: cell array of string names for arguments

function map = vararginProcessing(variableArguments, knownArgumentNames)

    % Check that all provided known arguments are strings: can't vectorize, its a cell!
    for i=length(knownArgumentNames),
        if(~strcmp(class(knownArgumentNames{i}), 'char')),
            error(['Known argument ' num2str(i) ' is not a string.']);
        end
    end

    % Keep track of what arguments we have seen
    alreadyFoundArgument = zeros(1, length(knownArgumentNames));
    numberOfKeysFound = 0;
    keysFound = [];
    valsFound = [];
    
    % Iterrate var args
    for i=1:2:length(variableArguments),
        
        % Get argument in question
        argument = variableArguments{i};

        % Check that it's a string
        if(~strcmp(class(argument),'char')),
            error(['Variable argument ' num2str(i) ' is not a string.']);
        end
        
        foundMatch = false;
        
        % Iterate known arguments, find match
        for j=1:length(knownArgumentNames),
            
            if(strcmp(argument, knownArgumentNames{j})),
                
                foundMatch = true;
                
                if(alreadyFoundArgument(j))
                    error(['Variable argument <' argument '> found more than ones in variable argument list.']);
                else
                    alreadyFoundArgument(j) = true;
                    numberOfKeysFound = numberOfKeysFound + 1;
                    
                    keysFound{numberOfKeysFound} = argument;
                    valsFound{numberOfKeysFound} = variableArguments{i + 1};                 
                end
                
            end
            
        end
        
        if(~foundMatch),
            error(['Variable argument ' num2str(i) ' is unfamiliar.']);
        end
        
    end
    
    % Create map and add keys/values
    map = containers.Map(keysFound, valsFound);
    
end