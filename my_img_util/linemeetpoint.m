function point = linemeetpoint( X1,Y1,X2,Y2 )
% X1, Y1, X2, Y2 ,point 都是点
% Matlab求四个点确定的两条直线的交点http://blog.sina.com.cn/s/blog_60b9b8890100t2b9.html

if X1(1)==Y1(1)
    X=X1(1);
    k2=(Y2(2)-X2(2))/(Y2(1)-X2(1));
    b2=X2(2)-k2*X2(1); 
    Y=k2*X+b2;
end
if X2(1)==Y2(1)
    X=X2(1);
    k1=(Y1(2)-X1(2))/(Y1(1)-X1(1));
    b1=X1(2)-k1*X1(1);
    Y=k1*X+b1;
end
if X1(1)~=Y1(1)&X2(1)~=Y2(1)
    k1=(Y1(2)-X1(2))/(Y1(1)-X1(1));
    k2=(Y2(2)-X2(2))/(Y2(1)-X2(1));
    b1=X1(2)-k1*X1(1);
    b2=X2(2)-k2*X2(1);
    if k1==k2
       X=[];
       Y=[];
    else
    X=(b2-b1)/(k1-k2);
    Y=k1*X+b1;
    end
end

point = [X Y];