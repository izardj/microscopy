function [ BW ] = segmentationPhaseContrast( I, varargin )
%SEGMENTATIONPHASECONTRAST Segmentation for phase contrast image.
%   Detailed explanation goes here

% Default values
options = struct( ...
    'fudge_factor', 2, ...
    'plot', false, ...
    'min_cell_size', 300);
 
while ~isempty(varargin)
    switch upper(varargin{1})
         
        case 'FUDGE FACTOR'
            options.fudge_factor = varargin{2};
            varargin(1:2) = [];
             
        case 'PLOT'
            options.plot = varargin{2};
            varargin(1:2) = [];
             
        case 'MIN CELL SIZE'
            options.min_cell_size = varargin{2};
            varargin(1:2) = [];
             
        otherwise
            error(['Unexpected option: ' varargin{1}])
    end
end

% convert to unsigned integer 8bits
originalImage = im2uint8(I);

%% edge and morphology detection
% options.plot original image
if (options.plot), figure, imshow(originalImage), title('original image'); end

% detect entire cell
[~, threshold] = edge(originalImage, 'sobel');
BWs = edge(originalImage,'sobel', threshold * options.fudge_factor);
if (options.plot), figure, imshow(BWs), title('binary gradient mask'); end

% dilate the image
se90 = strel('line', 3, 90);
se0 = strel('line', 3, 0);
BWsdil = imdilate(BWs, [se90 se0]);
if (options.plot), figure, imshow(BWsdil), title('dilated gradient mask'); end

% fill interior gaps
BWdfill = imfill(BWsdil, 'holes');
if (options.plot), figure, imshow(BWdfill), title('binary image with filled holes'); end

% remove connected objects on border
BWnobord = imclearborder(BWdfill, 4);
if (options.plot)
    figure, imshow(BWnobord), title('cleared border image');
end

% smoothen the object
seD = strel('diamond',1);
BWfinal = imerode(BWnobord,seD);
BWfinal = imerode(BWfinal,seD);
if (options.plot), figure, imshow(BWfinal), title('segmented image'); end

% remove small objects
BWfinal = bwareaopen(BWfinal, options.min_cell_size);
if (options.plot), figure, imshow(BWfinal), title('Binary image with no more small objects'); end

%% watershed treatment
% BW distance
D = -bwdist(~BWfinal);
if (options.plot), figure, imshow(D, []), title('BW distance'); end

% watershed
L = watershed(D);
if (options.plot)
    Lrgb = label2rgb(L);
    figure, imshow(Lrgb), title('Watershed');
end

%
bw2 = BWfinal;
bw2(L == 0) = 0;
if (options.plot), figure, imshow(bw2); end

mask = imextendedmin(D,2);
if (options.plot), figure, imshowpair(BWfinal,mask,'blend'); end

D2 = imimposemin(D,mask);
Ld2 = watershed(D2);
bw3 = BWfinal;
bw3(Ld2 == 0) = 0;
final = bw3;

if (options.plot)
    figure, imshow(final);

    cc = bwconncomp(final, 4);

    labeled = labelmatrix(cc);
    RGB_label = label2rgb(labeled, @spring, 'c', 'shuffle');
    figure, imshow(RGB_label), title('matrix');
end

% options.plot the original image with outline based on segmentation result
if (options.plot)
    BWoutline = bwperim(final);
    Segout = originalImage;
    Segout(BWoutline) = 255;
    figure, imshow(Segout), title('outlined original image');
end

BW = final;
end

