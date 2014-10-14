% Obtain ImageList & BoundingBoxList & LabelList
BoundingBoxList = importdata('./datasets/CUB_200_2011/list_bounding_boxes.txt');
BoundingBoxList(:,3) = BoundingBoxList(:,1) + BoundingBoxList(:,3)-1; %x2=x1+width
BoundingBoxList(:,4) = BoundingBoxList(:,2) + BoundingBoxList(:,4)-1; %y2=y1+height 
ImageList = importdata('./datasets/CUB_200_2011/list_images.txt');
Y_raw = importdata('./datasets/CUB_200_2011/list_image_class_labels.txt');
split = importdata('./datasets/CUB_200_2011/list_train_test_split.txt');

caffe('set_device',1); 
rcnn_model = rcnn_create_model(55,224,'./model-defs/VGG_ILSVRC_batch_55_output_fc6.prototxt', './data/caffe_nets/cub_finetune_iter_50000.caffemodel');
rcnn_model = rcnn_load_model(rcnn_model); rcnn_model.detectors.crop_mode = 'wrap'; rcnn_model.detectors.crop_padding = 32;
  
total_time = 0; X_trn = []; Y_trn = []; N_trn = 0; X_tst = []; Y_tst = []; N_tst = 0;
for i = 1:11788
  im = imread(['./datasets/CUB_200_2011/images/' ImageList{i}]);
  load(['/home/wangdequan/Fine-Grained/datasets/CUB_200_2011/MCG/' MatList{i} '.mat']);
  boxes = [candidates_scg.bboxes(:,2),candidates_scg.bboxes(:,1),candidates_scg.bboxes(:,4),candidates_scg.bboxes(:,3)];
  boxes = [BBoxList(i,:);[1,1,size(im,2),size(im,1)];boxes];
  boxes = FilterBoxesWidth(boxes, 99);
  boxes = BoxRemoveDuplicates(boxes);
  feat = rcnn_features(im, boxes, rcnn_model);
  save(['/home/wangdequan/Fine-Grained/datasets/CUB_200_2011/VGG_fc6/' MatList{List(i)}],'feat','boxes','-v7.3');
end

%fmxtrain_time = tic; model = train(Y_trn,sparse(X_trn),'-s 0');
%[Y_hat, accuracy, votes]=predict(Y_tst,sparse(X_tst),model);

%save('CUB_Image_Feature.mat','X_trn','Y_trn','X_tst','Y_tst','model','-v7.3'); exit;
