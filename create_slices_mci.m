function create_slices_mci(maskFileName,scanFileName,subjID,diagID,categories,foregroundKind,pre_path)




% read scan and mask
scan = nhdr_nrrd_read(scanFileName, true);
mask = nhdr_nrrd_read(maskFileName,true);
data = scan.data;

L = -600;
W =  1600;

data(data<(L-(W/2)))=L-(W/2);
data(data>(L+(W/2)))=L+(W/2);



dataFilter = mask.data;

delta_x = 0.9;
delta_y = 0.9;
delta_z = 0.9;


% select some slices
W = size(data,3);

% make sure that the data mask is zero or one
%dataFilter(dataFilter~=0) = 1;
dataFilterB = dataFilter;
if foregroundKind == 1
    dataFilterB(dataFilter==9) = 1;
    dataFilterB(dataFilter==10) = 1;
    dataFilterB(dataFilter==11) = 1;
    dataFilterB(dataFilter==12) = 1;
    dataFilterB(dataFilter==13) = 1;
    dataFilterB(dataFilter==14) = 1;
    dataFilterB(dataFilterB~=1) = 0;
else
    dataFilterB(dataFilter==20) = 1;
    dataFilterB(dataFilter==21) = 1;
    dataFilterB(dataFilter==22) = 1;
    dataFilterB(dataFilterB~=1) = 0;
end
dataFilter =dataFilterB;

for sigma = [1,3]
    [mci_masked,~]=compute_mci(data,dataFilter,delta_x,delta_y,delta_z,sigma);
    
    
    data_amount = zeros(W,1);
    for idx = 1:W
        %idx = floor(W*si);
        dataSlice = rescale(data(:,:,idx),0,1);
        dataSlice(isnan(dataSlice))=0;
        slice = dataSlice.*double(dataFilter(:,:,idx));
        data_amount(idx) = length(find(slice~=0));
    end
    data_amount = data_amount/(size(slice,1)*size(slice,2));
    data_amount = floor(data_amount*100);
    NonZInds = 1:W;
    ZInds = find(data_amount==0);
    NonZInds(ZInds) = [];
    slice_indices = floor(linspace(NonZInds(1),NonZInds(end),15));
    slice_indices = slice_indices(3:13);
    threshVal = 2.5;
    for idx = slice_indices
        dataSlice = mci_masked(:,:,idx);%.*double(dataFilter(:,:,idx));
        dataSlice(isnan(dataSlice))=0;
        dS = dataSlice;
        savePathColor = fullfile(strcat(fullfile(pre_path,categories{diagID}),'_color_',num2str(sigma)),strcat(num2str(subjID),'_',num2str(idx),'.jpg'));
        savePathGray = fullfile(strcat(fullfile(pre_path,categories{diagID}),'_gray_',num2str(sigma)),strcat(num2str(subjID),'_',num2str(idx),'.jpg'));
        dS(isnan(dS)) = 0;
        dS(dS>threshVal) = threshVal;
        dS(dS<-threshVal) = -threshVal;
        dSScaled = dS+threshVal;
        dSC = dSScaled;
        dSScaled = floor(dSScaled*1000);
        JRGB = jet(2000*threshVal);
        dSScaled(dSScaled<1) = 1;
        dSScaled(dSScaled>5000) = 5000;
        result = reshape(JRGB(dSScaled,:),[size(dataSlice,1),size(dataSlice,2),3]);
        finaloutput = result.*double(dataFilter(:,:,idx));
        grayFinalOutput = dSC/(2*threshVal).*double(dataFilter(:,:,idx));
        %         figure(1),imshow(finaloutput);
        %         figure(2),imshow(grayFinalOutput);
        imwrite(finaloutput,savePathColor);
        imwrite(grayFinalOutput,savePathGray);
    end
end


end
