function J = imshowforeground(IMAGE, METHOD)



switch upper(feature)
case 'light'
	% threshold = 200;%200;
	% I(I < threshold) = 0;he
	% I(I >= threshold) = 1; 
	% Binary = logical(I);
	threshold = graythresh(I);
	Binary = im2bw(I, threshold);
	Binary =  bwareaopen(Binary, 300 );
	
case 'histeq'
	I = histeq(I);
	% threshold = graythresh(I);
	Binary = im2bw(I, 243/255);