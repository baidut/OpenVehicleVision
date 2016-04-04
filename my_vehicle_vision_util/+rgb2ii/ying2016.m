function ii = ying2016(rgb, c)

    R1 = double(rgb(:,:,2)); % G
    R2 = double(rgb(:,:,3)); % B
    
    ii =  2 - (R1+c)./(R2+1); % +1 to avoid /0
    
    % matlab will do following when doing imshow
	ii(ii<0) = 0;
	ii(ii>1) = 1;
end

% MATLAB is very fast at parsing, so the PCODE function rarely makes much
% of a speed difference.
% just remember to do warming up (call once first, then do benchmarking)