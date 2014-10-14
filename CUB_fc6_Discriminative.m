% Obtain ImageList & BoundingBoxList & LabelList
BoundingBoxList = importdata('./datasets/CUB_200_2011/list_bounding_boxes.txt');
BoundingBoxList(:,3) = BoundingBoxList(:,1) + BoundingBoxList(:,3)-1; %x2=x1+width
BoundingBoxList(:,4) = BoundingBoxList(:,2) + BoundingBoxList(:,4)-1; %y2=y1+height 
ImageList = importdata('./datasets/CUB_200_2011/list_images.txt');
Y_raw = importdata('./datasets/CUB_200_2011/list_image_class_labels.txt');
Split = importdata('./datasets/CUB_200_2011/list_train_test_split.txt');
load('./datasets/CUB_BBox_Feature.mat'); load('CUB_Regions.mat');

%model = train(Y_trn,sparse(double(X_trn)),'-s 1');
[Y_hat,Accu,Votes] = predict(Y_tst,sparse(double(X_tst)),model);
[F_score,Precision,Recall] = Multi201(Y_hat,Y_tst,ones(1,200));


Y_trn_01 = zeros(5994,200); Y_tst_01 = zeros(5794,200); Y_hat_01 = zeros(5794,200);
for i=1:5994
  Y_trn_01(i,Y_trn(i,:)) = 1;
end
for i=1:5794
  Y_tst_01(i,Y_tst(i,:)) = 1;
end
for i=1:5794
  Y_hat_01(i,Y_hat(i,:)) = 1;
end

for k=1:200
  YY_trn = Y_trn_01(:,k); YY_tst = Y_tst_01(:,k);
  SVM_model(k) = train(YY_trn,sparse(double(X_trn)));
  [YY_hat,Accu,Votes] = predict(YY_tst,sparse(double(X_tst)),SVM_model(k));
  [F_score(k),Precision(k),Recall(k)] = fscore(YY_hat,YY_tst);
end

WaitingList = find(F_score<40); 
[X_WL_trn, Y_WL_trn, X_WL_tst, Y_WL_tst]=DataFromList(X_trn,Y_trn,X_tst,Y_tst,WaitingList);

WL_model = train(Y_WL_trn,sparse(double(X_WL_trn)),'-s 1');
Y_WL_hat = predict(Y_WL_tst,sparse(double(X_WL_tst)),WL_model);
[F_score,Precision,Recall] = Multi201(Y_WL_hat,Y_WL_tst,Label201(WaitingList));

caffe('set_device',2); 
rcnn_model = rcnn_create_model(1,224,'./model-defs/VGG_ILSVRC_batch_1_output_fc6.prototxt', './data/caffe_nets/cub_finetune_iter_50000.caffemodel');
rcnn_model = rcnn_load_model(rcnn_model); rcnn_model.detectors.crop_mode = 'wrap'; rcnn_model.detectors.crop_padding = 16;
  
total_time = 0; X_trn = []; Y_trn = []; N_trn = 0; X_tst = []; Y_tst = []; N_tst = 0;
for i = 30:30%1:11788
  if Split(i,:)==1 
  bbox = BoundingBoxList(i,:); dropout_feat = [];
  im_raw = imread(['./datasets/CUB_200_2011/images/' ImageList{i}]); bbox = BoundingBoxList(i,:);
  bbox(1) = max(1, bbox(1)); bbox(3) = min(size(im_raw,2), bbox(3)); 
  bbox(2) = max(1, bbox(2)); bbox(4) = min(size(im_raw,1), bbox(4));
  im = im_raw(bbox(2):bbox(4), bbox(1):bbox(3), :); imsize = [1 1 size(im,2) size(im,1)];
  im = imread(['./datasets/CUB_200_2011/images/' ImageList{i}]); 
  feat = rcnn_features(im,bbox,rcnn_model); predict(Y_raw(i,:),sparse(double(feat)),model);
  %for j=1:64
  %  boxes(j,1)=Regions(i,j,1); boxes(j,2)=Regions(i,j,2);
  %  boxes(j,3)=Regions(i,j,3); boxes(j,4)=Regions(i,j,4);
  %end
  %ssbox=selective_search_boxes(im); boxes=[ssbox(:,2),ssbox(:,1),ssbox(:,4),ssbox(:,3)];
  candidates_scg = im2mcg(im,'accurate'); boxes = [candidates_scg.bboxes(:,2),candidates_scg.bboxes(:,1),candidates_scg.bboxes(:,4),candidates_scg.bboxes(:,3)];
  boxes = BoxRemoveDuplicates(boxes); %boxes = FilterBoxesWidth(boxes, 99); 
  for j=1:size(boxes,1)
    dropout_feat(j,:)=rcnn_features(imdropout(im,boxes(j,:)), imsize, rcnn_model);
  end
  Y_tst = Y_raw(i,:).*ones(1,size(boxes,1))';
  [Y_hat,Accu,Votes] = predict(Y_tst,sparse(double(dropout_feat)),model);
  for j=1:size(boxes,1)
    showboxes(im,boxes(j,1:4));
   	pause;
  end
  end
end

%fmxtrain_time = tic; model = train(Y_trn,sparse(X_trn),'-s 0');
%[Y_hat, accuracy, votes]=predict(Y_tst,sparse(X_tst),model);

%save('CUB_Image_Feature.mat','X_trn','Y_trn','X_tst','Y_tst','model','-v7.3'); exit;
