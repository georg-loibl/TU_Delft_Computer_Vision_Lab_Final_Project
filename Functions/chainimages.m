%   function [PV] = chainimages(matches)
%   Construct the point-view matrix with the matches found between
%   consecutive frames. This matrix has tracked points as columns and
%   views/frames as rows, and contains the indices of the descriptor for
%   each frame. Therefore, if a certain descriptors can be seen in all
%   frames, their columns are completely filled. Similarly, if it can be 
%   matched only between frame 1 and 2, only the first 2 rows of the columns 
%   will be non-zero.
%
% Inputs:
% - matches: cell array containing matches, with descriptor indices for the
%   1st image in the 1st row, indices for the 2nd image in the 2nd row.
%   Each cell contains one frame pair (1-2, 2-3, 3-4, ... , 11-1).
%
% Outputs:
% - PV: matrix containing matches between consecutive frames

function [PV] = chainimages(matches)

    % number of views
    frames = size(matches,2);

    % Initialize PV
    % We add an extra row to process the match between frame_last and frame_1.
    % This extra row will be deleted at the end.
    PV = zeros(frames+1,size(matches{1},2));

    %  Starting from the first frame
    for i=1:frames
        newmatches = matches{i};
        
        % For the first pair, simply add the indices of matched points to the same
        % column of the first two rows of the point-view matrix.
        if i==1
            PV(1:2,:) = matches{1};
        else
            % Find already found points using intersection on PV(i,:) and newmatches 
            [~, IA, IB]  = intersect(PV(i,:), newmatches(1,:));
            PV(i+1, IA)  = newmatches(2,IB);
            
            % Find new matching points that are not in the previous match set using setdiff.
            [diff, IA] = setdiff(newmatches(1,:), PV(i,:));
            
            % Grow the size of the point view matrix each time you find a new match.
            start = size(PV,2)+1;
            PV    = [PV zeros(frames+1, size(diff,2))]; 
            PV(i, start:end)   = diff;
            PV(i+1, start:end) = newmatches(2,IA);
        end
    end

    % Process the last frame-pair. This part is already completed by TAs.
    % The last frame-pair, consisting of the last and first frames, requires special treatment.
    % Move matches between last & 1st frame to their corresponding columns in
    % the 1st frame, to prevent multiple columns for the same point.
    [~, IA, IB]      = intersect(PV(1, :), PV(end, :));
    PV(:, IA(2:end)) = PV(:, IA(2:end)) + PV(:, IB(2:end));  % skip 1st index (contains zeros)
    PV(:, IB(2:end)) = [];  % delete moved points in last frame

    % Copy the non zero elements from the last row which are not in the first row to the first row. 
    nonzero_last  = find(PV(end, :));
    nonzero_first = find(PV(1, :));
    no_member     = ~ismember(nonzero_last, nonzero_first);
    nonzero_last  = nonzero_last(no_member);
    tocopy        = PV(:, nonzero_last);

    % Place these points at the very beginning of PV
    PV(:, nonzero_last) = [];
    PV                  = [tocopy PV];

    % Copy extra row elements from last row to 1st row and delete the last row
    PV(1 ,1:size(tocopy, 2)) = PV(end, 1:size(tocopy, 2));
    PV                       = PV(1:frames,:); 
       
    disp(strcat(int2str(size(PV,2)), ' points in pointview matrix so far'));

end
