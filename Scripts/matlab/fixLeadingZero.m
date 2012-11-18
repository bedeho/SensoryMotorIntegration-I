    
% Make it prettier
function s = fixLeadingZero(d)

    s = num2str(d);

    if s(1) == '0' && length(s) > 1
      s = s(2:end);
    end

end