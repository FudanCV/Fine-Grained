% Obtain ImageList & BoundingBoxList & LabelList
ImageList = importdata('./datasets/CUB_200_2011/list_images.txt');
BoundingBoxList = importdata('./datasets/CUB_200_2011/list_bounding_boxes.txt');
BoundingBoxList(:,3) = BoundingBoxList(:,1) + BoundingBoxList(:,3)-1; %x2=x1+width
BoundingBoxList(:,4) = BoundingBoxList(:,2) + BoundingBoxList(:,4)-1; %y2=y1+height 
total_time = 0; MatList = importdata('./datasets/CUB_200_2011/list_mat.txt');

for i = 10963:11788
  fprintf('Fine-Grained Selective Search Regions Proposal: %d\n', i);
  tot_th = tic; bbox = BoundingBoxList(i,:);
  im = imread(['./datasets/CUB_200_2011/images/' ImageList{i}]);
  th = tic; boxes = selective_search_boxes(im);
  fprintf(' [features: %.3fs]\n', toc(th)); total_time = total_time + toc(tot_th);
  fprintf(' [avg time: %.3fs (total: %.3fs)]\n', total_time/i, total_time);
  save(['/home/wangdequan/Fine-Grained/datasets/CUB_200_2011/Selective_Search/' MatList{i}],'im','bbox','boxes','-v7.3');
end
