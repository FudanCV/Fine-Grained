function [F_score,Precision,Recall] = fscore(pl, tl)
%% Precision = true_positive / (true_positive + false_positive) 
%% Recall = true_positive / (true_positive + false_negative)
tp = 0; fp = 0; fn = 0; n = size(pl,1);
for i=1:n
  if ((pl(i)==1)&&(tl(i)==1)) tp = tp + 1; end
  if ((pl(i)==1)&&(tl(i)==0)) fp = fp + 1; end
  if ((pl(i)==0)&&(tl(i)==1)) fn = fn + 1; end
end

Precision = 100*tp/(tp+fp); Recall = 100*tp/(tp+fn);
%% F-score = 2 * Precision * Recall / (Precision + Recall) 
F_score = 2 * Precision * Recall / (Precision + Recall);

fprintf('F-score = %g%%\n',F_score);    
fprintf('Precision = %g%% (%d/%d)\n',Precision,tp,(tp+fp));
fprintf('Recall = %g%% (%d/%d)\n\n',Recall,tp,(tp+fn)); 

