function d = distanceP2L(P, Q1, Q2) % Point, LinePoint1, LinePoint2
% P-点坐标；Q1, Q2线上两点坐标

if length(P) == 3
	% 三维空间:
	d = norm(cross(Q2-Q1,P-Q1))/norm(Q2-Q1);
elseif length(P) == 2
	% 二维空间
	if (isrow(Q1) && isrow(Q2))
		d = abs(det([Q2-Q1;P-Q1]))/norm(Q2-Q1); % 坐标为行向量
	elseif (iscolumn(Q1) && iscolumn(Q2))
		d = abs(det([Q2-Q1,P-Q1]))/norm(Q2-Q1); % 坐标为列向量
	else 
		error('Q1/Q2 should be a vector.');
	end
end


% % 测试
% Q1 = [33, 12];
% Q2 = [13, 45];
% for ii = 1:100
% 	for jj = 1:100
% 		P = [ii, jj];
% 		MAP(ii, jj) = distanceP2L(P, Q1, Q2);
% 	end
% end
% implot(MAP);
% hold on;
% plot(Q1(2), Q1(1), 'r*');
% plot(Q2(2), Q2(1), 'r*');