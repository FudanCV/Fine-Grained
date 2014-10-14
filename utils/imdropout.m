function [im_dropout] = imdropout(im,box)
im_dropout = im;
box(1) = max(1,round(box(1)));
box(2) = max(1,round(box(2)));
box(3) = min(size(im,2),round(box(3)));
box(4) = min(size(im,1),round(box(4)));
%fprintf('Bounding Box: %d %d %d %d\n',box(1),box(2),box(3),box(4));
for j=box(1):box(3)
  for i=box(2):box(4)
    im_dropout(i,j,1) = 0;
    im_dropout(i,j,2) = 0;
    im_dropout(i,j,3) = 0;
  end
end
%imshow(im_dropout);