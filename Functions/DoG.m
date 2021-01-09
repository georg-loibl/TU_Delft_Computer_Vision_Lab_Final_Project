%function loc = DoG(im,tf)
%   uses the DoG (Difference of Gaussian) approximation of a Lapalcian for finding 
%   the scale of the local feature points.
%
%INPUT
%   -im: image
%   -tf: flatness threshold
%
%OUTPUT
%   -loc: a matrix of nx3 with n found locations with [c, r, sigma]

function loc = DoG(im,tf)
    im = rgb2gray(im);
    loc = [];

    % Prior smoothing sigma
    sigmaP = 1.6;
    levels = 7;
    
    % Scaling factor
    k = 2^(1/levels);
    noOctaves = 3;

    GP = cell(levels+3,1);
    for i = 1:levels+3
        GP{i} = gaussian( sigmaP*(k^(i-2)) );
    end

    % For all octaves
    for octave = 1:noOctaves
        % Gaussians for smoothing (i.e. scaling) and Gaussian smoothed images

        % Create the levels in the scale-space
        imG = cell(levels+3,1);
        for i = 1:levels+3
            imG{i} = conv2(GP{i},GP{i},im,'same');
        end
        
        % Computer the DoG (Difference of Gaussians)
        imDoG = zeros(size(im,1),size(im,2),levels+2);
        for i = 1:levels+2
            imDoG(:,:,i) = imG{i+1} - imG{i};
        end

        % Check nearby extrema in subsequent layers
        imExtrema = imregionalmax(imDoG);
        imExtrema = imExtrema(:,:,2:end-1);
        
        % Eliminate responses on the edge
        imExtrema(1,:,:) = 0;imExtrema(end,:,:) = 0;
        imExtrema(:,1,:) = 0;imExtrema(:,end,:) = 0;
        imDoG = imDoG(:,:,2:end-1);
    
        % Put local maxima in vector with corresponding sigma and test for
        % Flatness enhance location and eliminate edge responses
        for i = 1:levels

            % Current sigma and octave scale
            scale  = 2.0^(octave-1.0);
            sigmaC = scale*sigmaP*(k^(i-1));

            % Get extrma points
            [row,col] = find(imExtrema(:,:,i)==1);
 
            % Test for flatness
            flat = abs(diag(imDoG(row,col,i))) < tf;
            row = row(flat==0); col = col(flat==0);

            % Add new interest points to the list
            loc = [loc; round(scale*col),round(scale*row),...
                    repmat(sigmaC,length(row),1)];
        end
    
        % Next Octave is sub-sampling the image by half
        im = imresize(im,0.5);
    end
end
