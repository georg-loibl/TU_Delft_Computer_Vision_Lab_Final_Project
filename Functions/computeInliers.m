% function inliers = computeInliers(F,match1,match2,threshold)
% Find inliers by computing perpendicular errors between the points and the epipolar lines in each image
% To be brief, we compute the Sampson distance mentioned in the lab file.
% Input: 
%   -matrix F, matched points from image1 and image 2, and a threshold (e.g. threshold=50)
% Output: 
%   -inliers: indices of inliers
function inliers = computeInliers(F,match1,match2,threshold)

    % Calculate Sampson distance for each point
    % Compute numerator and denominator at first
    for i=1:1:size(match1,2)
        numer(i) = (match2(:,i)'*F*match1(:,i)).^2;
    end
    denom = (F(1,:)*match1).^2 + (F(2,:)*match1).^2 + (F(:,1)'*match2).^2 + (F(:,2)'*match2).^2;
   
    sd    = numer./denom;

    % Return inliers for which sd is smaller than threshold
    inliers = find(sd<threshold);

end
