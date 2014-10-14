function gen_Segmentation(config_file)
    global bdry;
    eval(config_file);
    outDir = sprintf('%ssegmentation/%d_%d',DIR.dataset,SPscale.Low,SPscale.High);
    mkdir(outDir);
    
    fid = fopen(PATH.trainingNames, 'r');
    trainImageNames = textscan(fid, '%s');
    trainImageNames = trainImageNames{1};
    fclose(fid);
    fid = fopen(PATH.testNames, 'r');
    testImageNames = textscan(fid, '%s');
    testImageNames = testImageNames{1};
    fclose(fid);

    imageNames = [trainImageNames' testImageNames'];
    imageNames = imageNames';

    ucmNames = strcat([DIR.ucm2, '/'], regexprep(imageNames, '\.\w+$', ''));
    ucmNames = strcat(ucmNames, DIR.ucm2_ext);
    
    outNames = strcat([outDir, '/'], regexprep(imageNames, '\.\w+$',''));
    
    labelNames = strcat([DIR.groundTruth, '/'], regexprep(imageNames, '\.\w+$', ''));
    labelNames = strcat(labelNames, DIR.groundTruth_ext);
    
    imageNames = strcat([DIR.images, '/'], regexprep(imageNames, '\.\w+$', ''));
    imageNames = strcat(imageNames, DIR.images_ext);
    
    numImages = numel(imageNames);
%     numImages = 5;
    
    Images_spDB = cell(1,numImages);
    offset = 0;
    wait = waitbar(0, 'preprocessing data');
    for i = 1:numImages
        tic;
        L = imread(labelNames{i});
        if size(L,3) > 1
            [r, c, d] = size(L);
            L = reshape(L, r*c, d);
            L2 = num2str(L, '%d%d%d');
            rgb = strtrim(cellstr(L2));
            ok = isKey(CLASSES, rgb);
            exceptions = find(ok==0);
            if size(exceptions,1) > 0
                ok = uint8(repmat(ok,1,3));
                L = L .* ok;
                L2 = num2str(L, '%d%d%d');
                rgb = strtrim(cellstr(L2));
            end
            L4 = double(cell2mat(values(CLASSES,rgb)));
            L = reshape(L4,r,c);
        end
        load(ucmNames{i},'ucm2');
        ucm = ucm2(3:2:end, 3:2:end);
        lbound = 0;
        hbound = 1;
        while( hbound - lbound > 0.0001 )
            k = (hbound + lbound ) / 2.0;
            bdry = zeros(size(ucm));
            bdry(ucm >= k) = 1;
            [counts,bdry] = segment_output(bdry',[outNames{i},'.seg']);
            disp(counts);
            if counts > SPscale.High
                lbound = k;
                continue;
            end
            if counts < SPscale.Low
                hbound = k;
                continue;
            end
            break;
        end
%             counts = 0;
%             for x = 1:size(bdry,1)
%                 for y = 1:size(bdry,2)
%                     if bdry(x,y) == 0
%                         counts = counts + 1;
%                         bdry = floodfill(bdry,x,y,counts);
%                     end
%                 end
%             end
%             disp(counts);
        bdry = bdry + 1;
        bdry(ucm >= k) = 0;
        spI = struct;
        spI.name = imageNames{i}(length(DIR.images)+2:length(imageNames{i})-length(DIR.images_ext));
        spI.offset = offset;
        spI.SpNum = counts;
        spI.SpImage = bdry;
        %spI.SpImage = bdry - (ucm >= k);
        offset = offset + spI.SpNum;
        spI.ImLabels = tabulate(L(:));
        spI.ImLabels = spI.ImLabels(:,1);
        spI.ImLabels = spI.ImLabels(spI.ImLabels > 0);
        Images_spDB{i} = spI;
        imwrite((ucm >= k),[outNames{i},sprintf('_%d.bmp',spI.SpNum)]);
        toc;
        wait = waitbar(i/numImages, wait, sprintf(['preprocessing segment ' ...
                            'image: %d'], i));
    end
    close(wait);
    TotalSP = offset;
    save(Dataset.spDB,'Images_spDB','TotalSP');
end