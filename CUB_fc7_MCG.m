% Obtain ImageList and BoundingBoxList
BBoxList = importdata('./datasets/CUB_200_2011/list_bounding_boxes.txt');
BBoxList(:,3) = BBoxList(:,1) + BBoxList(:,3)-1; %x2=x1+width-1
BBoxList(:,4) = BBoxList(:,2) + BBoxList(:,4)-1; %y2=y1+height-1 
ImageList = importdata('./datasets/CUB_200_2011/list_images.txt');
MatList = importdata('./datasets/CUB_200_2011/list_mat.txt');
Label = importdata('./datasets/CUB_200_2011/list_image_class_labels.txt');
Split = importdata('./datasets/CUB_200_2011/list_train_test_split.txt'); 

minBoxWidth = 20; caffe('set_device',1); 
rcnn_model = rcnn_create_model(55,224,'./model-defs/VGG_ILSVRC_19_layers_batch_55_fc6.prototxt', './data/caffe_nets/VGG_ILSVRC_19_layers.caffemodel');
rcnn_model = rcnn_load_model(rcnn_model);
rcnn_model.detectors.crop_mode = 'wrap';
rcnn_model.detectors.crop_padding = 16;

for i=129:130%1:11788
  if Split(i,:)==1 % 1 for train && 0 for test
  	im = imread(['/home/wangdequan/Fine-Grained/datasets/CUB_200_2011/images/' ImageList{i}]);
  	%candidates_scg = im2mcg(im,'accurate');
  	load(['/home/wangdequan/Fine-Grained/datasets/CUB_200_2011/MCG/' MatList{i} '.mat']);
  	boxes = [candidates_scg.bboxes(:,2),candidates_scg.bboxes(:,1),candidates_scg.bboxes(:,4),candidates_scg.bboxes(:,3)];
  	boxes = [BBoxList(i,:);[1,1,size(im,2),size(im,1)];boxes];
  	boxes = FilterBoxesWidth(boxes, minBoxWidth);
    boxes = BoxRemoveDuplicates(boxes);
  	for j=1:size(boxes,1)
      boxes(j,5)=boxoverlap(boxes(j,:),BBoxList(i,:));
  	end
  	boxes = sortrows(boxes,-5);
  	
  	for j=1:size(boxes,1)
    	showboxes(im,boxes(j,1:4));
    	pause;
    end
  end
end

