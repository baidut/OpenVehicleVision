function recover3dlayout(file)
% filename = 'shadowy_road';
% filename = 'weak_shadows';
% filename = 'lakecomo2008';
% filename = 'clean_road';
% filename = 'shadowy';

[pathstr,name,ext] = fileparts(file);

% if ext~= 'jpg'
% ext = '.jpg';

I = imread(file);
imwrite(I,[name '.ppm']);

dos(['photoPopupIjcv data/ijcvClassifier ' file ' "" results']);

w=vrview(['results/' name '.wrl']);

ext = '.pgm';

Support = imread(['results/', name, '.000', ext]);
Vertical = imread(['results/',name, '.090', ext]);
Sky = imread(['results/',name, '.sky', ext]);

implot(I, Support, Vertical, Sky);


% |Class|X|Y|
% Support 	000		.g
% Vertical  090 	.v
% Left 		090 135
% Center 	090 090
% Right 	090 045
% Sky 		.sky
% Porous 	-por
% Solid		-sol