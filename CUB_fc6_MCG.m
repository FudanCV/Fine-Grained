% Obtain ImageList and BoundingBoxList
BBoxList = importdata('./datasets/CUB_200_2011/list_bounding_boxes.txt');
BBoxList(:,3) = BBoxList(:,1) + BBoxList(:,3)-1; %x2=x1+width-1
BBoxList(:,4) = BBoxList(:,2) + BBoxList(:,4)-1; %y2=y1+height-1 
ImageList = importdata('./datasets/CUB_200_2011/list_images.txt');
MatList = importdata('./datasets/CUB_200_2011/list_mat.txt');
Label = importdata('./datasets/CUB_200_2011/list_image_class_labels.txt');
Split = importdata('./datasets/CUB_200_2011/list_train_test_split.txt'); 
tot=0; fn=fopen('cub_full_selective_finetune_train.txt','w'); List=randperm(11788); 
for i=1:11788
  if Split(List(i),:)==1 % 1 for train && 0 for test
  	tot=tot+1; im = imread(['/home/wangdequan/Fine-Grained/datasets/CUB_200_2011/images/' ImageList{List(i)}]);
  	candidates_scg = im2mcg(im,'accurate'); save(['/home/wangdequan/Fine-Grained/datasets/CUB_200_2011/MCG/' MatList{List(i)} '.mat'],'candidates_scg','-v7.3');
  	boxes = [candidates_scg.bboxes(:,2),candidates_scg.bboxes(:,1),candidates_scg.bboxes(:,4),candidates_scg.bboxes(:,3)];
  	boxes=[BBoxList(List(i),:);[1,1,size(im,2),size(im,1)];boxes]; fprintf(fn,'# %d\n',tot-1); 
  	fprintf(fn,'/home/wangdequan/Fine-Grained/datasets/CUB_200_2011/images/%s\n',ImageList{List(i)});
  	fprintf('#%d: CUB_200_2011/%s\n',tot,ImageList{List(i)});
  	fprintf(fn,'%d\n%d\n%d\n',size(im,3),size(im,1),size(im,2));
  	for j=1:size(boxes,1)
      boxes(j,5)=boxoverlap(boxes(j,:),BBoxList(List(i),:));
  	end
    fprintf(fn,'%d\n',size(boxes,1));
    for j=1:size(boxes,1)
	    fprintf(fn,'%d %.3f %d %d %d %d\n',Label(List(i)),boxes(j,5),boxes(j,1),boxes(j,2),boxes(j,3),boxes(j,4));
    end
  end
end
fclose(fn);