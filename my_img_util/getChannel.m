function [varargout] = getChannel(A)
%GETJFRAME get channels of an image.
% USAGE:
% 	[R,G,B] = getChannel( imread('picture.jpg') );
% there is a more convenient way to display
	% >> I = imread('s1.png'); imshow(I)
	% >> J = [I(:,:)]; imshow(J)

error(nargchk(1,1,nargin));

% for size
% size(A)可以得到矩阵A的大小
% length(size(A))可以得到矩阵A的维数

s = size(A);

if ( length(s) ~= 3 )
	error('The dimensions of Array must be 3.')
end 
channels = s(end);

for c = 1 : channels
	varargout{c} = A(:,:,c); 
end