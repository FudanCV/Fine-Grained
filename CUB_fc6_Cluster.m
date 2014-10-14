load('CUB_BBox_Feature.mat'); load('Cluster.mat');

CountCluster = zeros(1,26);
for i=1:70
  Num = size(find(Cluster(i,:)>0),2); CountCluster(Num) = CountCluster(Num) + 1;
end

for i=1:5994
  Cluster_Y_trn(i,:) = ClassGroup(Y_trn(i,:),:);
end
for i=1:5794
  Cluster_Y_tst(i,:) = ClassGroup(Y_tst(i,:),:);
end

model = train(Cluster_Y_trn,sparse(X_trn));
Cluster_Y_hat = predict(Cluster_Y_tst,sparse(X_tst),model);

