function [ acquisition_time, channel_name ] = parseCziMetadata( metadata )
%PARSECZIMETADATA Parse metadata from ZEISS .czi image file.
%   Detailed explanation goes here

    metadataKeys = metadata.keySet().iterator();
    % iterates through all metadata
    for i=1:metadata.size()
            key = metadataKeys.nextElement();
            value = metadata.get(key);
        % look for channel names
        if ~isempty(strfind(key, 'Global Information|Image|Channel|Name #'))
            channel_number = str2num(key(end));
            channel_name{channel_number} = value; % TODO: pre-allocate vector 
            continue;
        end
        % look for acquisition time
        if ~isempty(strfind(key, 'Global Information|Image|AcquisitionDateAndTime'))
            acquisition_time = value;
        end
    end
end

