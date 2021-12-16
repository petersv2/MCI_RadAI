function create_slices_mci_2(maskFileName,scanFileName,subjID,diagID,categories,foregroundKind)


% read scan and mask
scan = nhdr_nrrd_read(scanFileName, true);
mask = nhdr_nrrd_read(maskFileName,true);
data = scan.data;




L = -600;
W =  1600;

data(data<(L-(W/2)))=L-(W/2);
data(data>(L+(W/2)))=L+(W/2);
copyData = data;


dataFilter = mask.data;

delta_x = size(dataFilter,1);
delta_y = size(dataFilter,2);
delta_z = size(dataFilter,3);
sigma = 3;
data=compute_mci(data,dataFilter,0.9,0.9,0.9,sigma);


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
    dataSlice = data(:,:,idx);%.*double(dataFilter(:,:,idx));
    originalSlice = rescale(copyData(:,:,idx),0,1).*double(rescale(dataFilter(:,:,idx),0,1));
    originalSlice(isnan(originalSlice)) = 0;
    
    dataSlice(isnan(dataSlice))=0;
    dS = dataSlice;
    savePath = fullfile(categories{diagID},strcat(num2str(subjID),'_',num2str(idx),'.jpg'));
%     slice = rescale(dataSlice,0,1);
%     %     figure;
%     %     imshow(slice);
%     
%     
%     D = slice;
%     
%     dF = dataFilter(:,:,idx);
%     dF(dF~=0) = 1;
%     dF = uint8(dF*255);
%     
%     E = D.*double(dF)/255.0;
%     [DV,bins] = histcounts(E,100);
%     DV(bins == 0) = 0;
%     T = find(DV~=0);
%     minV = min(bins(T));
%     maxV = max(bins(T));
%     golden_value = maxV-minV
%     finaloutput = (E-minV)/(maxV-minV);
%     %    finaloutput = DD.*double(dF)/255.0;
    
    
    
    
    dS(isnan(dS)) = 0;
    dS(dS>threshVal) = 0;
    dS(dS<-threshVal) = 0;
    dSScaled = dS+threshVal;
    dSScaled = floor(dSScaled*1000);
    JRGB = jet(2000*threshVal);
    dSScaled(dSScaled<1) = 1;
    dSScaled(dSScaled>5000) = 5000;
    result = reshape(JRGB(dSScaled,:),[size(dataSlice,1),size(dataSlice,2),3]);

    for i = 1 : size(result,1)
        for j = 1 : size(result,2)
            if result(i,j,1) == 0.5 && result(i,j,2) == 1 && result(i,j,3) == 0.5
                result(i,j,1) = originalSlice(i,j);
                result(i,j,2) = originalSlice(i,j);
                result(i,j,3) = originalSlice(i,j);
            end
        end
    end
%     for i = 1 : size(result,2)
%         for j = 1 : size(result,2)
%             if result(i,j,1) == 0 && result(i,j,2) == 0 && result(i,j,3) == 0
%             end
%         end
%     end
    
    
    finaloutput = result.*double(dataFilter(:,:,idx));
    imwrite(finaloutput,savePath);
end



end
