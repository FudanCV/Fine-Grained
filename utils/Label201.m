function Label_01 = Label201(Label,m)
n = size(Label,2); 
if nargin<2; m = max(Label); end 
Label_01 = zeros(1,m);
for i=1:n Label_01(Label(i))=1; end
