BoundingBoxList = importdata('./datasets/CUB_200_2011/list_bounding_boxes.txt');
BoundingBoxList(:,3) = BoundingBoxList(:,1) + BoundingBoxList(:,3)-1; %x2=x1+width
BoundingBoxList(:,4) = BoundingBoxList(:,2) + BoundingBoxList(:,4)-1; %y2=y1+height 
MatList = importdata('./datasets/CUB_200_2011/list_mat.txt');
ImageList = importdata('./datasets/CUB_200_2011/list_images.txt'); 
%load('CUB_Regions.mat'); image_mean = load('./external/caffe/matlab/caffe/ilsvrc_2012_mean.mat');

X_trn = []; Y_trn = []; N_trn = 0; X_tst = []; Y_tst = []; N_tst = 0; 
cache_opts = []; padx = 0; pady = 0; total_time = 0; USE_GPU = true; USE_CAFFE = true; 
caffe('set_device',1); cnn = init_cnn_model('use_gpu', USE_GPU, 'use_caffe', USE_CAFFE);

for i = 1:11788
  fprintf('Fine-Grained ILSVRC fc6 Features: %d\n', i);
  tot_th = tic; bbox = BoundingBoxList(i,:); features = [];
  im_raw = imread(['./datasets/CUB_200_2011/images/' ImageList{i}]);
  bbox(1) = max(1, bbox(1)); bbox(3) = min(size(im_raw,2), bbox(3)); 
  bbox(2) = max(1, bbox(2)); bbox(4) = min(size(im_raw,1), bbox(4));
  th = tic; %features = rcnn_features(im, boxes, rcnn_model);
  %im = rcnn_im_crop(im, bbox, 'wrap', crop_size, 16, image_mean);
  window = im_raw(bbox(2):bbox(4), bbox(1):bbox(3), :);
  im = permute(imresize(window, [227 227], 'bilinear', 'antialiasing', false), [2 1 3]);
  %pyra = deep_pyramid(im, cnn, cache_opts);
  pyra = deep_pyramid_add_padding(deep_pyramid(im, cnn, cache_opts), padx, pady);
  fprintf(' [features: %.3fs]\n', toc(th)); total_time = total_time + toc(tot_th);
  fprintf(' [avg time: %.3fs (total: %.3fs)]\n', total_time/i, total_time);
  save(['./datasets/CUB_200_2011/DeepPyramid/' MatList{i}],'pyra','-v7.3');
end
exit;

