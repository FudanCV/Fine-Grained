% Obtain ImageList & BoundingBoxList & ClusterList
BoundingBoxList = importdata('./datasets/CUB_200_2011/list_bounding_boxes.txt');
BoundingBoxList(:,3) = BoundingBoxList(:,1) + BoundingBoxList(:,3)-1; %x2=x1+width
BoundingBoxList(:,4) = BoundingBoxList(:,2) + BoundingBoxList(:,4)-1; %y2=y1+height 
ImageList = importdata('./datasets/CUB_200_2011/list_images.txt'); 

% Set up OUTPUT dir
output_dir = ['./feat_cache/ALL_CUB_dense_finetuning/'];
mkdir_if_missing(output_dir);

for iter=12:12
% load the CNN model
rcnn_model = rcnn_create_model('./model-defs/CUB_dense_finetuning_output_pool6.prototxt', ['./data/caffe_nets/CUB_finetuning_dense_iter_' num2str(iter*2500)]);
rcnn_model = rcnn_load_model(rcnn_model);
rcnn_model.detectors.crop_mode = 'wrap';
rcnn_model.detectors.crop_padding = 16;

% load the region of interest database

% Log feature extraction
timestamp = datestr(datevec(now()), 'dd.mmm.yyyy:HH.MM.SS');
diary_file = [output_dir 'CUB_finetuning_iter_fc6_test_clustering' num2str(iter*2500) '_' timestamp '.txt'];
diary(diary_file); fprintf('Logging output in %s\n', diary_file);
fprintf('\n\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n');

%Load CNN features and class labels
Y = importdata('./datasets/CUB_200_2011/list_image_class_labels.txt');
split = importdata('./datasets/CUB_200_2011/list_train_test_split.txt');

%Coarse Clustering
Cluster_X_trn = []; 
Cluster_Y_trn = [];
Cluster_N_trn = 0; 
Cluster_X_tst = []; 
Cluster_Y_tst = []; 
Cluster_N_tst = 0;

for i=1:11788
  if split(i,:) == 1
    if ismember(Y(i,:),Cluster)
      boxes = BoundingBoxList(i,:);
      im = imread(['./datasets/CUB_200_2011/images/' ImageList{i}]);
      X(i,:) = rcnn_features(im, boxes, rcnn_model);
      Cluster_N_trn = 1 + Cluster_N_trn;
      Cluster_X_trn(Cluster_N_trn,:) = X(i,:);
      Cluster_Y_trn(Cluster_N_trn,:) = Y(i,:);
    end
  else
    if ismember(Y(i,:),Cluster)
      boxes = BoundingBoxList(i,:);
      im = imread(['./datasets/CUB_200_2011/images/' ImageList{i}]);
      X(i,:) = rcnn_features(im, boxes, rcnn_model);
      Cluster_N_tst = 1 + Cluster_N_tst;
      Cluster_X_tst(Cluster_N_tst,:) = X(i,:);
      Cluster_Y_tst(Cluster_N_tst,:) = Y(i,:);
    end
  end
end

model = train(Cluster_Y_trn,sparse(Cluster_X_trn));
Cluster_Y_hat = predict(Cluster_Y_tst,sparse(Cluster_X_tst),model);

%From Coarse to Fine-Grained


%Calculate Accuracy
fprintf('\nAccuracy %f\n', length(find(Y_hat==Y_tst))/length(Y_tst));
fprintf('\n\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n');
end
