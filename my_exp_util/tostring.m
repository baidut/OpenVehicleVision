function str = tostring(var)
%TOSTRING convert a var to a string for code generation.
% the result string is the value of that variable or null if the
% value cannot be displayed in one single line (eg. matrix, image data).
% try following example to understand what it does:
%
%   tostring(@imshow) 		% @imshow
%	tostring('hello') 		% 'hello'
%   tostring(3) 			% 3
%   tostring(pi) 			% 3.1416
%   tostring([10 30]) 		% [10 30]

switch class(var)
    % first handle some special cases
    case 'function_handle' %isscalar
        str = sprintf('@%s',char(var));
    case 'char' %ischar(var)
        str = ['''' var ''''];
    otherwise
        % then handle other cases
        if isscalar(var)
            str = strtrim(evalc('disp(var)'));
        elseif size(var,1)==1&&size(var,2)==2
            str = sprintf('[%s,%s]',tostring(var(1)),tostring(var(2)));
        else
            str = '';
        end
end

end