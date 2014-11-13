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
        % metadata from ZEISS
        metadata = bfImage{1, 2};
        [acquisition_time, channel_name] = parseCziMetadata(metadata);
        
        % add metadata to dataset
        dataset{i}.file_path = file_path;
        dataset{i}.acquisition_time = acquisition_time;
        dataset{i}.channel_name = channel_name;
        
        nb_channel = length(channel_name);
        channel{nb_channel} = 0;
        for j=1:nb_channel
            dataset{i}.channel{j} = bfImage{1,1}{j};
        end
    end
end

