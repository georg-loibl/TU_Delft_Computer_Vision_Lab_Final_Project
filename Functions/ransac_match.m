%%  Apply normalized 8-point RANSAC algorithm to find best matches
% Input:
%     - C: coordinates of interest points
%     - D: descriptors of interest points
%     - optional: Files containing directories of images, if provided plots
%                 are made
% Output:
%     - Matches: Matches (between each two consecutive pairs, including the last & first pair)

function [Matches] = ransac_match(C, D, Files)
    
    if nargin < 3
        optional_plot_RANSAC = 0;
    else
        optional_plot_RANSAC = 1;
    end
    
    % Initialize Matches (between each two consecutive pairs)
    Matches={};
    
    n = size(C,2);
    for i=1:n
        
        next = mod(i,n)+1;
        
        coord1 = C{i};
        desc1  = D{i};
        
        coord2 = C{next};
        desc2  = D{next};
        
        disp(['Matching Descriptors for image ' num2str(i) ' and image ' num2str(next)]);drawnow('update')
        % Find matches according to extracted descriptors using vl_ubcmatch
        match_thres = 1.15;
        match = vl_ubcmatch(desc1, desc2, match_thres);
        disp(strcat(int2str(size(match,2)), ' matches found'));drawnow('update')
        
        % Obtain X,Y coordinates of matches points
        match1 = coord1(:, match(1,:));
        match2 = coord2(:, match(2,:));
        
        %% Find inliers using normalized 8-point RANSAC algorithm
        [~, inliers] = estimateFundamentalMatrix(match1,match2);
        drawnow('update')
        Matches{i} = match(:,inliers);
        
        %% Optional plot of matches
        if optional_plot_RANSAC
            % Plot all matches
            figure; 
            im1 = imread([Files(i).folder '\' Files(i).name]);
            im2 = imread([Files(next).folder '\' Files(next).name]);
            imshow([im1 im2]); hold on; 
            line([match1(1,1:150); size(im1,2)+match2(1,1:150)],...
                 [match1(2,1:150);             match2(2,1:150)]);
            title(['Image ' num2str(i) ' and ' num2str(next) ' with the original points and their transformed counterparts in image ' num2str(next)]);
            % Plot first 60 inliers and first 60 outliers
            number = 60;
            figure; 
            im1 = imread([Files(i).folder '\' Files(i).name]);
            im2 = imread([Files(next).folder '\' Files(next).name]);
            imshow([im1 im2]); hold on; 
            line([match1(1,inliers(1:number)); size(im1,2)+match2(1,inliers(1:number))],...
                 [match1(2,inliers(1:number));             match2(2,inliers(1:number))], 'Color', 'b');
            title(['Image ' num2str(i) ' and ' num2str(next) ' with the original points and their transformed counterparts in image ' num2str(next)]);
            [~, outliers] = setdiff([1:1:size(match,2)], inliers);
            line([match1(1,outliers(1:number)); size(im1,2)+match2(1,outliers(1:number))],...
                 [match1(2,outliers(1:number));             match2(2,outliers(1:number))], 'Color', 'r');
        end
        
    end

end
