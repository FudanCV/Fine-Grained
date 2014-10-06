MatList = importdata('./datasets/CUB_200_2011/list_mat.txt');
Y_raw = importdata('./datasets/CUB_200_2011/list_image_class_labels.txt');
split = importdata('./datasets/CUB_200_2011/list_train_test_split.txt');
X_trn = []; Y_trn = []; N_trn = 0; X_tst = []; Y_tst = []; N_tst = 0; 

for i = 1:11788
  load(['./datasets/CUB_200_2011/DeepPyramid/' MatList{i}]);
  for k=1:pyra.num_levels
    current = reshape(pyra.feat{k},1,pyra.level_sizes(k)*pyra.level_sizes(k)*256);
    features = [features,current];
  end
  if split(i,:) == 1
    N_trn = N_trn + 1;
    X_trn(N_trn,:) = features;
    Y_trn(N_trn,:) = Y_raw(i,:);
  else
    N_tst = N_tst + 1;
    X_tst(N_tst,:) = features;
    Y_tst(N_tst,:) = Y_raw(i,:);
  end
end
save('CUB_DeepPyramid.mat','X_trn','X_tst','Y_trn','Y_tst','-v7.3'); 

train_time = tic; model = train(Y_trn,sparse(X_trn),'-s 0');
[Y_hat, accuracy, votes]=predict(Y_tst,sparse(X_tst),model);

Check=votes; Check(:,201)=Y_hat; Check(:,202)=Y_tst; AP=[];
for class=1:200
  tot = 0; ok = 0.0;
  Check = sortrows(Check,-class);
  for i=1:N_tst
    if Check(i,202) == class
       tot = tot + 1; ok = ok + tot/i;
    end
  end
  AP(class) = ok/tot;
end

fprintf(' [time: %.3fs] mAP %f\n', toc(train_time), mean(AP));

