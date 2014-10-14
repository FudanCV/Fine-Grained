
%% Demo to show the results of the Ultrametric Contour Map obtained by MCG
clear all;close all;home;

imgDir = '/home/wangdequan/CNN/datasets/VOCdevkit2012/VOC2012/JPEGImages';
outDir = '/home/wangdequan/external/MCG/VOC2012/';
mkdir(outDir);
fid = fopen('/home/zengsheng/MCG-Full/VOC2012/test.txt','r');
testImageNames = textscan(fid,'%s');
testImageNames = testImageNames{1};

for i = 1:numel(testImageNames)
    outFile = fullfile(outDir,[testImageNames{i} '.mat']);
    if exist(outFile,'file'), continue;end
    I = imread(fullfile(imgDir,[testImageNames{i} '.jpg']));
    tic;
    ucm2 = im2ucm(I,'accurate');
    toc;
    save(outFile,'ucm2');
end
