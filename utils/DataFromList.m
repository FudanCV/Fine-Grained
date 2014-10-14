function [X_WL_trn, Y_WL_trn, X_WL_tst, Y_WL_tst]=DataFromList(X_trn,Y_trn,X_tst,Y_tst,WaitingList)

X_WL_trn = []; Y_WL_trn = []; N_WL_trn = 0; 
X_WL_tst = []; Y_WL_tst = []; N_WL_tst = 0;

for i=1:size(X_trn,1)
  if (ismember(Y_trn(i,:),WaitingList))
    N_WL_trn = N_WL_trn + 1;
    X_WL_trn(N_WL_trn,:) = X_trn(i,:);
    Y_WL_trn(N_WL_trn,:) = Y_trn(i,:);
  end
end

for i=1:size(X_tst,1)
  if (ismember(Y_tst(i,:),WaitingList))
    N_WL_tst = N_WL_tst + 1;
    X_WL_tst(N_WL_tst,:) = X_tst(i,:);
    Y_WL_tst(N_WL_tst,:) = Y_tst(i,:);
  end
end
