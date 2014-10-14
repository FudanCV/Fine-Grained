function  [F_score,Precision,Recall] = Multi201(Y_hat,Y_tst,Flag)
m=size(Flag,2); n=size(Y_tst,1); Y_tst_01 = zeros(n,m); Y_hat_01 = zeros(n,m);
for i=1:n
  Y_tst_01(i,Y_tst(i,:)) = 1;
end
for i=1:n
  Y_hat_01(i,Y_hat(i,:)) = 1;
end

for k=1:m
  if (Flag(k))
    fprintf('No.%d:\n',k);
    YY_hat = Y_hat_01(:,k); YY_tst = Y_tst_01(:,k);
    fprintf('Accuracy = %g%%\n',100*size(find(YY_hat==YY_tst),1)/n);    
    [F_score(k),Precision(k),Recall(k)] = fscore(YY_hat,YY_tst);
  end
end
    
