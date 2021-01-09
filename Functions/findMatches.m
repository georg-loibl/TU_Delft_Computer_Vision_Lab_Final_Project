% Finds matching SIFT descriptors at Harris corner points in two images.
% inputs:
%		im1 - first image to match
%		im2 - second image to match
% outputs:
%		coord1 - the corrdinates in image 1
%		coord2 - the corrdinated in image 2 matches to the ones in image 1
%		desc1 - the corrdinated in image 2 matches to the ones in image 1
%		desc2 - the corrdinated in image 2 matches to the ones in image 1

function [coord, desc] = findMatches(im1, im2)
    
    if nargin < 2
        im2 = 0;
        optional_plot = 0;
    else
        optional_plot = 1;
    end
    
    %%
    DoG_threshold = 0.7;
    
    % Find features and make descriptor of image 1
    loc1                  = DoG(im1, DoG_threshold);
    [r1, c1, sigma1]      = harris(im2double(rgb2gray(im1)), loc1);
    orient1               = zeros(size(sigma1));

    % Pay attention to the oder of parameters [c',r'] (equal to [x,y])
    [coord, desc] = vl_sift(single(im2double(rgb2gray(im1))), 'frames', [c1'; r1'; sigma1'; orient1']);
    %  Custom implementation of sift. You can compare this result with your own implementation.
%     [coord, desc] = vl_sift(single(im2double(rgb2gray(im1))), 'Peakthresh', 0.008, 'EdgeThresh', 8);

%% Plot both images next to each other

if optional_plot
    % Find features and make descriptor of image 2
    loc2                  = DoG(im2, DoG_threshold);
    [r2, c2, sigma2]      = harris(im2double(rgb2gray(im2)), loc2);
    orient2               = zeros(size(sigma2));
    [coord2, desc2] = vl_sift(single(im2double(rgb2gray(im2))), 'frames', [c2'; r2'; sigma2'; orient2']);
    %  Custom implementation of sift. You can compare this result with your own implementation.
%     [coord2, descriptor2] = vl_sift(single(im2double(rgb2gray(im2))), 'Peakthresh', 0.008, 'EdgeThresh', 8);

    % Show images with scatter plot on each image for the features
    % Note: Images must be same size

    figure; imshow([im1, im2]); hold on;
    scatter(coord(1,:), coord(2,:), coord(3,:), [1,1,0]);
    scatter(size(im1,2)+coord2(1,:), coord2(2,:), coord2(3,:), [1,1,0]);
    drawnow;
end

end
