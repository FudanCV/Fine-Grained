% Obtain ImageList and BoundingBoxList
BBoxList = importdata('./datasets/CUB_200_2011/list_bounding_boxes.txt');
BBoxList(:,3) = BBoxList(:,1) + BBoxList(:,3)-1; %x2=x1+width-1
BBoxList(:,4) = BBoxList(:,2) + BBoxList(:,4)-1; %y2=y1+height-1 
ImageList = importdata('./datasets/CUB_200_2011/list_images.txt');
Label = importdata('./datasets/CUB_200_2011/list_image_class_labels.txt');
Split = importdata('./datasets/CUB_200_2011/list_train_test_split.txt'); 
tot=0; fn=fopen('CUB_selective_accu_coarse_larger_finetune_train.txt','w'); 
List=randperm(11788); load('Cluster.mat');
MatList = importdata('./datasets/CUB_200_2011/list_mat.txt');
for i=1:11788
  if Split(List(i),:)==1 % 1 for train && 0 for test
  tot=tot+1; im = imread(['/home/wangdequan/Fine-Grained/datasets/CUB_200_2011/images/' ImageList{List(i)}]);
  load(['/home/wangdequan/Fine-Grained/datasets/CUB_200_2011/Selective_Search/' MatList{List(i)}]);
  boxes = FilterBoxesWidth(boxes, 20); boxes = BoxRemoveDuplicates(boxes);
  boxes = [boxes(:,2),boxes(:,1),boxes(:,4),boxes(:,3)]; threshold = 0.29;
  %ssbox=selective_search_boxes(im); ssbox=[ssbox(:,2),ssbox(:,1),ssbox(:,4),ssbox(:,3)];
  boxes=[BBoxList(List(i),:);[1,1,size(im,2),size(im,1)];boxes]; 
  fprintf(fn,'# %d\n',tot-1); 
  fprintf(fn,'/home/wangdequan/Fine-Grained/datasets/CUB_200_2011/images/%s\n',ImageList{List(i)});
  fprintf('#%d: CUB_200_2011/%s\n',tot,ImageList{List(i)});
  fprintf(fn,'%d\n%d\n%d\n',size(im,3),size(im,1),size(im,2));
  SizeBoxes = 0;
  for j=1:size(boxes,1)
    boxes(j,5)=boxoverlap(boxes(j,:),BBoxList(List(i),:));
    if (boxes(j,5)>threshold)
      SizeBoxes = SizeBoxes + 1;
    end
  end
  %boxes=sortrows(boxes,-5); RP=boxes(50:size(boxes,1),:); NMSL=nms(RP,0.29); boxes=boxes(1:49,:);
  %for j=1:size(NMSL)
  %  boxes(49+j,:)=RP(NMSL(j),:);
  %end
  fprintf(fn,'%d\n',SizeBoxes); 
  CoarseLabel = ClassGroup(Label(List(i)));
  FineLabel = Label(List(i));
  for j=1:SizeBoxes
    if (boxes(j,5)>threshold)
	    fprintf(fn,'%d %.3f %d %d %d %d\n',CoarseLabel,boxes(j,5),boxes(j,1),boxes(j,2),boxes(j,3),boxes(j,4));
    end
  end
  end
end
fclose(fn);
