clear all;
addpath(genpath('Lib'))
sessions = {'Morteza','Morteza2'}%,'Morteza3'};
subjectFile = importdata('subjects2.txt');
diagFile = importdata('diag_code_new2.txt');

pre_path = fullfile('..','..','Google Drive','Research','Data');
categoriesToMake = {'Control_color_1','Control_color_3','Control_gray_1','Control_gray_3','Disease_color_1','Disease_color_3','Disease_gray_1','Disease_gray_3'};
categories = {'Control','Disease'};
for i =1 : length(categoriesToMake)
    mkdir(fullfile(pre_path,categoriesToMake{i}));
end
for sess = sessions 
    cur_sess= sess{1};
    files = dir(cur_sess);
    dirFlags = [files.isdir];
    subFolders = files(dirFlags);
    for fi = 1 : length(subFolders)
        curFold = subFolders(fi).name;
        
        if strcmp(curFold,'.')~=1 && strcmp(curFold,'..')~=1
            folderPath = fullfile(cur_sess,curFold);
            scanFileName = fullfile(folderPath,'series_interp.nhdr');
            maskFileName = fullfile(folderPath,'partialLungLabelMap_interp.nhdr');
            foregroundKind = 1;
            if ~isfile(maskFileName)
                % File does not exist.
                maskFileName = fullfile(folderPath,'mask_interp.nhdr');
                foregroundKind = 2;
            end
 
            subjID = str2double(curFold);            
            actualdiagID = diagFile(subjectFile==subjID);
            if actualdiagID == 5
                diagID = 1;
            else
                diagID = 2;
            end
            create_slices_mci(maskFileName,scanFileName,subjID,diagID,categories,foregroundKind,pre_path)
        end
    end
end
