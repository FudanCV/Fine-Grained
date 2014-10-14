%load('CUB_Image_Feature.mat'); Y_hat=predict(Y_tst,sparse(X_tst),model);
clear; load('CUB_BBox_Feature.mat'); con = confusionmat(Y_tst,Y_hat);

con = (con + con')/2; cls = ncutW(con,20); sum(cls)
for i=1:200
  coarse2fine(i) = find(cls(i,:)==1);
end

for i=1:5994
  Y_trn(i,:) = coarse2fine(Y_trn(i,:));
end

for i=1:5794
  Y_tst(i,:) = coarse2fine(Y_trn(i,:));
end

model = train(Y_trn,sparse(X_trn),'-s 0');
Y_hat = predict(Y_tst,sparse(X_tst),model);
