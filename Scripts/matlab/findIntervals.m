    
% pts    = y values of points
% offset = x value of first point
% delta  = distance between consecutive points

% test:  hold on;g=rand(1,10);disp(g);plot(g);plot(ones(1,length(g))*mean(g));findIntervals(g,1,1)
function intervals = findIntervals(pts, offset, delta)
    
    avg = mean(pts)
    isInInterval = false;
    intervals = [];
        
    % a_i = intervals(1,i) 
    % b_i = intervals(2,i)
        
    for j=1:length(pts),
            
        % we are in interval,
        if(isInInterval)

            % and next is below:
            % start b_i at intersection and set isInterval <- false
            if(pts(j) < avg)
                b_i = findIntercept();
                intervals(2,end) = b_i;

                % Indicate that we are not in an interval
                isInInterval = false;
            end
            
        else % we are not in interval

            % and next is above:
            % start a_i at intersection and set isInterval <- true
            if(pts(j) > avg)

                if(j == 1)
                    a_i = offset;
                else
                    a_i = findIntercept(); % interpoalte start of interval
                end
                
                %add an extra column for new interval: save begining value of interval
                intervals = [intervals [a_i; 0]];

                % Indicate that we are in an interval
                isInInterval = true;
            end
            
        end
    end
        
    % If we ended while in interval, we have to close up 
    if(isInInterval)
        intervals(2,end) = offset + (length(pts)-1)*delta;
    end

    % Solve: y_1 + slope * intercept_x = const;
    function intercept_x = findIntercept()
        
        %offset + (j-2)*delta + findIntercept(, , avg, delta); % interpoalte end of interval
        
        slope = (pts(j) - pts(j-1))/delta;
        intercept_x = offset + (j-2)*delta + (avg - pts(j-1))/slope;

    end

end
