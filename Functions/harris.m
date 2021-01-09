function [r, c, sigmas] = harris(im, loc)
    % inputs: 
    % im: double grayscale image
    % loc: list of interest points from the Laplacian approximation
    % outputs:
    % [r,c,sigmas]: The row and column of each point is returned in r and c
    %              and the sigmas 'scale' at which they were found
    
    % Calculate Gaussian Derivatives at derivative-scale. 
    % NOTE: The sigma here is for computing the image derivatives. 
    % It is independent of the window size (Which depends on the Laplacian /DoG responses).

    % Hint: use your previously implemented function in assignment 1 
    % Use a small sigma: 0.6 here
    Ix =  ImageDerivatives(im , 0.6, 'x'); 
    Iy =  ImageDerivatives(im , 0.6, 'y'); 

    % Allocate an 3-channel image to hold the 3 parameters for each pixel: Ix^2, Iy^2 and IxIy
    init_M = zeros(size(Ix,1), size(Ix,2), 3);

    % Calculate M for each pixel: Ix^2, Iy^2, IxIy
    init_M(:,:,1) = Ix.^2;
    init_M(:,:,2) = Ix.*Iy;
    init_M(:,:,3) = Iy.^2;

    % Allocate the size of R 
    R = zeros(size(im,1), size(im,2), 2);

    % Smooth M with a gaussian at the integration scale sigma.
    % Keep only points from the list 'loc' that are coreners. 
    for l = 1 : size(loc,1)
        sigma = loc(l,3); % The sigma at which we found this point	

    	% The response accumulation over a window of size '2k sigma + 1' (Where k is the Gaussian cutoff: it can be 1, 2, 3).
        if ((l>1) && sigma~=loc(l-1,3)) || (l==1)
            M = imfilter(init_M, fspecial('gaussian', ceil(sigma*2+1), sigma), 'replicate', 'same');
        end
	
        % Compute the cornerness R at the current location location
        trace_l = M(loc(l,2),loc(l,1),1)+M(loc(l,2),loc(l,1),3);
        det_l = M(loc(l,2),loc(l,1),1).*M(loc(l,2),loc(l,1),3)-M(loc(l,2),loc(l,1),2).^2;
        R(loc(l,2), loc(l,1), 1) = det_l - 0.04*trace_l.^2;

    	% Store current sigma as well
        R(loc(l,2), loc(l,1), 2) = sigma;

    end

    % Set the threshold 
    threshold = max(max(R(:,:,1)))*0.0005; % Try also 0.3 to retain less corners; used 0.0005 instead to get more feature points

    % Find local maxima
    % Dilation will alter every pixel except local maxima in a 3x3 square area.
    % Also checks if R is above threshold
    R(:,:,1) = ((R(:,:,1)>threshold) & ((imdilate(R(:,:,1), strel('square', 3))==R(:,:,1)))) ; 
       
    % Return the coordinates r, c and sigmas
    [r, c] = ind2sub(size(R(:,:,1)), find(R(:,:,1) == 1));
    RSigmas = R(:,:,2);
    sigmas = RSigmas(sub2ind(size(RSigmas), r, c));

    % Display corners
    optional_plot = 0;
    if optional_plot
        figure
        imshow(im,[]);
        hold on;
        for i = 1:1:length(r)
            viscircles([c(i) r(i)], 2*sigmas(i)+1, 'LineWidth', 0.5);
        end
        title('Harris Detector Corners with circle radii of corresponding \sigma'); 
    end
end
