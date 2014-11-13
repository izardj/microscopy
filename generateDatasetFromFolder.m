function [ dataset ] = generateDatasetFromFolder( folder_path )
%GENERATEDATASETFROMFOLDER Generate dataset from images.
%   [ dataset ] = generateDatasetFromFolder( folder_path) reads images from
%   folder_path and store them in the dataset cell.

    % list all files from the folder_path
    file_information = rdir(folder_path); 
    file_name = {file_information.name};

    % count number of images in the folder
    nb_file = length(file_name);
    
    % pre-allocate the cell
    dataset{nb_file} = struct();
    
    % read each image file
    for i=1:nb_file
        file_path = [file_name{i}];
        % open image file using Bio-Formats library
        bfImage = bfopen(file_path);
        
        % read metadata from Bio-Formats
        omeMeta = bfImage{1, 4};
        nb_channel = omeMeta.getChannelCount(0);
        
        % add metadata to dataset
        dataset{i}.file_path = file_path;
        dataset{i}.acquisition_date = omeMeta.getImageAcquisitionDate(0).getValue();
        
        channel_name = cell(1,nb_channel);
        for j=1:nb_channel
            dataset{i}.channel{j} = bfImage{1,1}{j};
            channel_name{j} = char(omeMeta.getChannelName(0,(j-1)));
        end
        dataset{i}.channel_name = channel_name;
        
    end
end

