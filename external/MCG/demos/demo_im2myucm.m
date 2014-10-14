
%% Demo to show the results of MCG
clear all;close all;home;

% Read an input image
I = imread(fullfile(root_dir, 'demos','2007_000648.jpg'));

tic;
% Test the 'fast' version, which takes around 5 seconds in mean
[candidates_scg, ucm2_scg] = im2mcg(I,'fast');
toc;

tic;
% Test the 'accurate' version, which tackes around 30 seconds in mean
[candidates_mcg, ucm2_mcg] = im2mcg(I,'accurate');
toc;

ucm_mcg = ucm2_mcg(3:2:end,3:2:end);

tic;
% totalbb = numel(candidates_mcg.labels);
% combinemask = zeros(size(ucm_mcg));
% for bb = 1:totalbb
%     mask = ismember(candidates_mcg.superpixels, candidates_mcg.labels{bb});
%     combinemask = max(combinemask,single(mask)*candidates_mcg.scores(bb));
% end
% ucm_mcg = ucm_mcg - ucm_mcg.*combinemask;
toc;


