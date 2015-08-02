function [hA] = subplott(nr,nc)
%function to return a figure handle and axes handles for tight subplots
%
%Inputs:
%  r: number of rows
%  c: number of columns
%
%Outputs:
%  hA: axes handles to subplots (styled order, i.e. rows first then columns)
%
%See Also: subplot imshow
%
% http://www.mathworks.com/matlabcentral/answers/28673-imshow-border-tight-for-subplot
      %Error Checking:
      assert(nargin==2,'2 inputs expected');
      assert(isscalar(nr)&&isscalar(nc));
      %Other Constants:
      rspan = 1./nr; %row span normalized units
      cspan = 1./nc; %not the tv channel
      na = nr*nc; %num axes
      %Engine  
      rlow = flipud(cumsum(rspan(ones(nr,1)))-rspan); %lower edge
      clow = cumsum(cspan(ones(nc,1)))-cspan;
      [rg cg] = meshgrid(1:nr,1:nc); %grids
      hA = zeros(na,1);
      figure;
      for ii = 1:na
          pos = [clow(cg(ii)) rlow(rg(ii)) cspan rspan]; %positions
          hA(ii) = axes('units','norm','outerposition',pos,'position',pos); %build axes
      end 
  end