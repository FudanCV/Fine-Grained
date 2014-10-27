% Obtain ImageList & BoundingBoxList & LabelList
BoundingBoxList = importdata('./datasets/CUB_200_2011/list_bounding_boxes.txt');
BoundingBoxList(:,3) = BoundingBoxList(:,1) + BoundingBoxList(:,3)-1; %x2=x1+width
BoundingBoxList(:,4) = BoundingBoxList(:,2) + BoundingBoxList(:,4)-1; %y2=y1+height 
ImageList = importdata('./datasets/CUB_200_2011/list_images.txt'); load('Cluster.mat');
Y_raw = importdata('./datasets/CUB_200_2011/list_image_class_labels.txt');
split = importdata('./datasets/CUB_200_2011/list_train_test_split.txt');

caffe('set_device',1); load('./cache/test_det_boxes.mat'); load('./cache/train_det_boxes.mat');
rcnn_model = rcnn_create_model(1,224, './model-defs/VGG_ILSVRC_batch_1_output_fc7.prototxt', './data/caffe_nets/CUB_20_selective_fine_iter_130000.caffemodel'); 
rcnn_model = rcnn_load_model(rcnn_model); rcnn_model.detectors.crop_mode = 'wrap'; rcnn_model.detectors.crop_padding = 8;
  
total_time = 0; X_trn = []; Y_trn = []; N_trn = 0; X_tst = []; Y_tst = []; N_tst = 0;
Y = importdata('./datasets/CUB_200_2011/list_image_class_labels.txt');
split = importdata('./datasets/CUB_200_2011/list_train_test_split.txt');

for i = 1:11788
  if split(i,:) == 1
    N_trn = N_trn + 1; boxes = train_det_boxes(N_trn,:);
  else
    N_tst = N_tst + 1; boxes = test_det_boxes(N_tst,:);
  end
  fprintf('Fine-Grained VGG fc7 Features: %d\n', i); tot_th = tic; 
  im = imread(['./datasets/CUB_200_2011/images/' ImageList{i}]);
  th = tic; features = rcnn_features(im, boxes, rcnn_model);
  fprintf(' [features: %.3fs]\n', toc(th)); total_time = total_time + toc(tot_th);
  fprintf(' [avg time: %.3fs (total: %.3fs)]\n', total_time/i, total_time);
  if split(i,:) == 1
    X_trn(N_trn,:) = features;
    Y_trn(N_trn,:) = ClassGroup(Y(i,:));
    %Y_trn(N_trn,:) = Y(i,:);
  else
    X_tst(N_tst,:) = features;
    Y_tst(N_tst,:) = ClassGroup(Y(i,:));
    %Y_tst(N_tst,:) = Y(i,:);
  end
end

train_time = tic; model = train(Y_trn,sparse(X_trn),'-s 1');
[Y_hat, accuracy, votes]=predict(Y_tst,sparse(X_tst),model);

N_trn = 0; Y_trn = []; N_tst = 0; Y_tst = [];
for i = 1:11788
  if split(i,:) == 1
    N_trn = N_trn + 1;
    %Y_trn(N_trn,:) = ClassGroup(Y(i,:));
    Y_trn(N_trn,:) = Y(i,:);
  else
    N_tst = N_tst + 1;
    %Y_tst(N_tst,:) = ClassGroup(Y(i,:));
    Y_tst(N_tst,:) = Y(i,:);
  end
end

train_time = tic; model = train(Y_trn,sparse(X_trn),'-s 1');
[Y_hat, accuracy, votes]=predict(Y_tst,sparse(X_tst),model);
