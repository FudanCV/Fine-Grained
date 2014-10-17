Y = importdata('./datasets/CUB_200_2011/list_image_class_labels.txt');
Split = importdata('./datasets/CUB_200_2011/list_train_test_split.txt');
load('./cache/Det_Coarse.mat'); X_trn_coarse = X_trn; X_tst_coarse = X_tst;
load('./cache/Det_Fine.mat'); X_trn_fine = X_trn; X_tst_fine = X_tst;
X_trn = [X_trn_coarse,X_trn_fine]; X_tst = [X_tst_coarse,X_tst_fine];

N_trn = 0; Y_trn = []; N_tst = 0; Y_tst = []; load('Cluster.mat');
for i = 1:11788
  if Split(i,:) == 1
    N_trn = N_trn + 1;
    %Y_trn(N_trn,:) = ClassGroup(Y(i,:));
    Y_trn(N_trn,:) = Y(i,:);
  else
    N_tst = N_tst + 1;
    %Y_tst(N_tst,:) = ClassGroup(Y(i,:));
    Y_tst(N_tst,:) = Y(i,:);
  end
end

model = train(Y_trn,sparse(X_trn),'-s 0');
[Y_hat, accuracy, votes]=predict(Y_tst,sparse(X_tst),model);
