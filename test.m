folderPath = fullfile('Data','01');

%the 3D CT image in nrrd format
scanFileName = fullfile(folderPath,'series_interp.nhdr');

%the 3D lung mask in nrrd format
maskFileName = fullfile(folderPath,'partialLungLabelMap_interp.nhdr');


% read scan and mask
scan = nhdr_nrrd_read(scanFileName, true);
mask = nhdr_nrrd_read(maskFileName,true);
data = scan.data;
dataFilter = mask.data;


% select some slices 
W = size(data,3);
idx1 = floor(W*0.35);
idx2 = floor(W*0.62);
idx3 = floor(W*0.75);
idx4 = floor(W*0.87);


% make sure that the data mask is zero or one
dataFilter(dataFilter~=0) = 1;


% read the slices
data1 = rescale(data(:,:,idx1),0,1);
data1(isnan(data1))=0;
slice1 = data1.*double(dataFilter(:,:,idx1));

data2 = rescale(data(:,:,idx2),0,1);
data2(isnan(data2))=0;
slice2 = data2.*double(dataFilter(:,:,idx2));

data3 = rescale(data(:,:,idx3),0,1);
data3(isnan(data3))=0;
slice3 = data3.*double(dataFilter(:,:,idx3));

data4 = rescale(data(:,:,idx4),0,1);
data4(isnan(data4))=0;
slice4 = data4.*double(dataFilter(:,:,idx4));


% create a montage
montage = [slice1,slice2;slice3,slice4];
imshow(montage);


% apply data augmentation if you like 
% ...

 theta = pi/20;
 t = [cos(theta)  0      -sin(theta)   0
     0             1              0     0
     sin(theta)    0       cos(theta)   0
     0             0              0     1];
tform = affine3d(t);
maskAUG = imwarp(dataFilter,tform);
data(isnan(data)) = 0;
dataAUG = imwarp(data,tform);

data1AUG = rescale(dataAUG(:,:,idx1),0,1);
slice1AUG = data1AUG.*double(maskAUG(:,:,idx1));

data2AUG = rescale(dataAUG(:,:,idx2),0,1);
slice2AUG = data2AUG.*double(maskAUG(:,:,idx2));

data3AUG = rescale(dataAUG(:,:,idx3),0,1);
slice3AUG = data3AUG.*double(maskAUG(:,:,idx3));

data4AUG = rescale(dataAUG(:,:,idx4),0,1);
slice4AUG = data4AUG.*double(maskAUG(:,:,idx4));

montageAUG = [slice1AUG,slice2AUG;slice3AUG,slice4AUG];
figure;
imshow(montageAUG);


