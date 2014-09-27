% Obtain ImageList & BoundingBoxList & LabelList
BoundingBoxList = importdata('./datasets/CUB_200_2011/list_bounding_boxes.txt');
BoundingBoxList(:,3) = BoundingBoxList(:,1) + BoundingBoxList(:,3)-1; %x2=x1+width
BoundingBoxList(:,4) = BoundingBoxList(:,2) + BoundingBoxList(:,4)-1; %y2=y1+height 
ImageList = importdata('./datasets/CUB_200_2011/list_images.txt'); load('CUB_Regions.mat');
Y_raw = importdata('./datasets/CUB_200_2011/list_image_class_labels.txt');
split = importdata('./datasets/CUB_200_2011/list_train_test_split.txt');

rcnn_model = rcnn_create_model(32,'./model-defs/CUB_batch_32_output_fc6.prototxt', './data/caffe_nets/cub_finetune_train_iter_50000');
rcnn_model = rcnn_load_model(rcnn_model); rcnn_model.detectors.crop_mode = 'wrap'; rcnn_model.detectors.crop_padding = 16;

X_trn = []; Y_trn = []; N_trn = 0; X_tst = []; Y_tst = []; N_tst = 0; N_ROI = 32;
for i = 1:11788
  fprintf('%s: CNN Feature: #%d\n', procid(), i);
  for j=1:N_ROI
    boxes(j,1)=Regions(i,j,1);
    boxes(j,2)=Regions(i,j,2);
    boxes(j,3)=Regions(i,j,3);
    boxes(j,4)=Regions(i,j,4);
  end
  im = imread(['./datasets/CUB_200_2011/images/' ImageList{i}]); 
  features = rcnn_features(im, boxes, rcnn_model); label = Y_raw(i,:);
  if split(i,:) == 1
    for j=1:N_ROI
      X_trn(N_trn*N_ROI+j,:)=features(j,:);
      Y_trn(N_trn*N_ROI+j,:)=label;
    end
    N_trn = N_trn + 1;
  else
    for j=1:N_ROI
      X_tst(N_tst*N_ROI+j,:)=features(j,:);
      Y_tst(N_tst*N_ROI+j,:)=label;
      Z_tst(N_tst*N_ROI+j,:)=boxoverlap(boxes(j,:),boxes(1,:));
    end
    N_tst = N_tst + 1;
    Label(N_tst) = Y_raw(i,:);
  end
end

%Train and test LibLinearSVM
model = train(Y_trn,sparse(X_trn),'-s 0');
[Y_hat,accuracy, votes]=predict(Y_tst,sparse(X_tst),model);

%Calculate mAP
PC = zeros(N_tst,200); TopN=5; tot = 0; 
for i=1:N_tst*N_ROI
  PC(ceil(i/N_ROI),Y_hat(i,:)) = PC(ceil(i/N_ROI),Y_hat(i,:)) + Z_tst(i,:);
end
for i=1:N_tst
  rerank=PC(i,:)';
  for j=1:200
    rerank(j,2)=j;
  end
  rerank=sortrows(rerank,-1); candidate=rerank(1:TopN,2)';
  N_local_trn=0; X_local_trn=[]; Y_local_trn=[]; PC_local=zeros(1,200);
  for j=1:N_trn*N_ROI
    if ismember(Y_trn(j,:),candidate)
      N_local_trn = N_local_trn+1;
      X_local_trn(N_local_trn,:) = X_trn(j,:);
      Y_local_trn(N_local_trn,:) = Y_trn(j,:);
    end
  end
  X_local_tst = X_tst(i*N_ROI-N_ROI+1:i*N_ROI,:);
  Y_local_tst = Y_tst(i*N_ROI-N_ROI+1:i*N_ROI,:);
  Z_local_tst = Z_tst(i*N_ROI-N_ROI+1:i*N_ROI,:);
  local_model = train(Y_local_trn,sparse(X_local_trn),'-s 0');
  Y_local_hat = predict(Y_local_tst,sparse(X_local_tst),local_model);
  for j=1:N_ROI
    PC_local(Y_local_hat(j,:)) = PC_local(Y_local_hat(j,:)) + Z_local_tst(j,:);
  end
  if PC_local(Label(i))==max(PC_local(:))
    tot = tot + 1;
  end
end

fprintf('Top %d : %.3f\n', TopN, tot/N_tst);
