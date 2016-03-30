function ii_image = alverez2011inv(image, alpha)
% map to 0-1
	ii_image = 1- GetInvariantImage(image, alpha*360, 0, 1);
end