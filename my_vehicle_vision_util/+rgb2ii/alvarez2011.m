function ii_image = alverez2011(image, alpha, inv)
% map to 0-1
	ii_image = GetInvariantImage(image, alpha*360, 0, 1); % 1
	if inv
		ii_image = 1- ii_image;
	end
end