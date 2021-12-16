function create_slices(maskFileName,scanFileName,subjID,diagID,categories,foregroundKind)


% read scan and mask
scan = nhdr_nrrd_read(scanFileName, true);
mask = nhdr_nrrd_read(maskFileName,true);
data = scan.data;


L = -600;

W =  1600;

data(data<(L-(W/2)))=L-(W/2);
data(data>(L+(W/2)))=L+(W/2);



dataFilter = mask.data;



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
for idx = slice_indices
    dataSlice = rescale(data(:,:,idx),0,1);
    dataSlice(isnan(dataSlice))=0;
    slice = dataSlice.*double(dataFilter(:,:,idx));
%     figure;
%     imshow(slice);
    savePath = fullfile(categories{diagID},strcat(num2str(subjID),'_',num2str(idx),'.jpg'));
    imwrite(slice,savePath);
end



end