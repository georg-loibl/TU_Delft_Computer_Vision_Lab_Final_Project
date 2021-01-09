vl_setup;
clear;
close all;

%% Final Project - Castle and Teddy Bear 3D Reconstruction

% Georg Loibl
% Martijn van Wezel
% April 2019

%% Select Object and Feature Extraction type
% Which object would you like to reconstruct?
% 1 - Model Castle
% 2 - Teddy Bear

object = 2;

% Would you like to use your own Harris Detector or use the given features?
% 1 - Use own Harris Detector (plus SIFT)
% 2 - Use given features

featureDetectionOption = 2;

%% Open the specified folder and read images. 
%  (Path to your local image directory)
disp(' ');
disp('----------------------------------------------------------------');
disp('----------------------------------------------------------------');

switch object
    case 1
        directory = 'modelCastle_features\';
        Files = dir(strcat(directory, '*.png'));
        disp('Selected object: Model Castle');
    case 2
        directory = 'teddyBear_features\';
        Files = dir(strcat(directory, '*.png'));
        disp('Selected object: Teddy Bear');
    otherwise
        error('Object does not exist! Choose another object number.');
end
nImages = length(Files);
disp('----------------------------------------------------------------');
disp(' ');
    
if(nImages==0)
    % sometimes files are not found...
    error(['No files are found! Path',pwd]);
end

%% PART 1 - Feature Detection and Matching

switch featureDetectionOption
    case 1
        if exist(strcat(directory, 'C_own.mat')) && exist(strcat(directory, 'D_own.mat'))
            load(strcat(directory, 'C_own.mat'));
            load(strcat(directory, 'D_own.mat'));
        else
            % Initialize coordinates C and descriptors D
            C ={};
            D ={};
            for i = 1:1:nImages
                next = mod(i,nImages)+1;
                disp(['Feature Extraction of image ' num2str(i)]);drawnow('update')
                im = imread([Files(i).folder '\' Files(i).name]);
%                 im2 = imread([Files(next).folder '\' Files(next).name]); % uncomment this line and
                [coord, desc] = findMatches(im);                           % add second image as input here to make a plot
                C{i} = coord(1:2, :);
                D{i} = desc;
            end
            save(strcat(directory, 'C_own.mat'), 'C');
            save(strcat(directory, 'D_own.mat'), 'D');  
        end
    case 2
    %  Load given features
    disp('PART 1 - Feature Detection and Matching');
    disp('Load saved features');

    if exist(strcat(directory, 'C.mat')) && exist(strcat(directory, 'D.mat'))
        load(strcat(directory, 'C.mat'));
        load(strcat(directory, 'D.mat'));
    else
        % Initialize coordinates C and descriptors D
        C ={};
        D ={};
        % Load all features (coordinates and descriptors of interest points)
        % As an example, we concatenate the haraff and hesaff sift features
        % You can also use features extracted from your own Harris function.
        for i=1:nImages
            disp('image num');
            disp(i);
            [coord_haraff,desc_haraff,~,~] = loadFeatures(strcat(directory, '/',Files(i).name, '.haraff.sift'));
            [coord_hesaff,desc_hesaff,~,~] = loadFeatures(strcat(directory, '/',Files(i).name, '.hesaff.sift'));

            coord = [coord_haraff coord_hesaff];
            desc  = [desc_haraff desc_hesaff];

            C{i} = coord(1:2, :);
            D{i} = desc;
        end
        save(strcat(directory, 'C.mat'), 'C');
        save(strcat(directory, 'D.mat'), 'D');
    end
    otherwise
        error('Feature Detection Option does not exist. Choose another option.');
end
    
%% PART 2 - Normalized 8-point RANSAC
%  Apply normalized 8-point RANSAC algorithm to find best matches.
%  The output includes indies (Matches)for all matched pairs.
disp('PART 2 - Normalized 8-point RANSAC');

switch featureDetectionOption
    case 1
        if exist(strcat(directory, 'Matches_own.mat'))
            disp('Load saved matches');
            load(strcat(directory, 'Matches_own.mat'));
        else
            disp('Calculate matches');
            Matches = ransac_match(C, D);
            save(strcat(directory, 'Matches_own.mat'), 'Matches');
        end
    case 2
        if exist(strcat(directory, 'Matches.mat'))
            disp('Load saved matches');
            load(strcat(directory, 'Matches.mat'));
        else
            disp('Calculate matches');
            Matches = ransac_match(C, D);
            save(strcat(directory, 'Matches.mat'), 'Matches');
        end
end

%% PART 3 - Chaining
%  Create point-view matrix (PV) to represent point correspondences 
%  for different camera views.
disp('PART 3 - Chaining');

switch featureDetectionOption
    case 1
        if exist(strcat(directory, 'PV_own.mat'))
            load(strcat(directory, 'PV_own.mat'));
        else
            [PV] = chainimages(Matches);
            save(strcat(directory, 'PV_own.mat'), 'PV');
        end
    case 2
        if exist(strcat(directory, 'PV.mat'))
            load(strcat(directory, 'PV.mat'));
        else
            [PV] = chainimages(Matches);
            save(strcat(directory, 'PV.mat'), 'PV');
        end
end


%% PART 4/5 - Stitching / Eliminate affine ambiguity
%  Affine Structure from Motion / Eliminate affine ambiguity
disp('PART 4/5 - Stitching');

%% 4a) Take blocks of the point-view matrix

% Stitch every 3 images together to create a point cloud.
Clouds = {};
i = 1;
numFrames = 3;
cloudNumber = [];

for iBegin = 1:nImages-(numFrames - 1)
    iEnd = iBegin+numFrames-1;

    % Select frames from the PV matrix to form a block
    block = PV(iBegin:iEnd,:);

    % Select columns from the block that do not have any zeros
    colInds = find(all(block~=0,1));

    % Check the number of visible points in all views
    numPoints = size(colInds, 2);
    if numPoints < 8
        continue
    end

    % Create measurement matrix X with coordinates instead of indices using the block and the 
    % Coordinates C 
    block = block(:, colInds);
    X = zeros(2 * numFrames, numPoints);
    for f = 1:numFrames
        for p = 1:numPoints
            X(2 * f - 1, p) = C{iBegin-1+f}(1, block(f,p));
            X(2 * f, p)     = C{iBegin-1+f}(2, block(f,p)); 
        end
    end
    
    %% 4b) 
    % Estimate 3D coordinates of each block following Lab 4 "Structure from Motion" to compute the M and S matrix.
    % Here, an additional output "p" is added to deal with the non-positive matrix error
    % Please check the chol function inside sfm.m for detail.
    [M, S, p] = structureFromMotion(X);
    
    % Save the M matrix and Meanvalues for the first frame. In this example,the
    % first frame is the camera plane (view) where every point will be projected
    % Please do check if M is non-zero before selection. Otherwise, you
    % have to select another view
    if i==1 && ~p
        M1 = M(1:2,:);
        MeanFrame1 = sum(X,2)/numPoints;
    end

    if ~p
        % Compose Clouds in the form of (M,S,colInds)
        Clouds(i, :) = {M, S, colInds};
        i = i + 1;
        cloudNumber(end+1) = iBegin;
    end
end

% By an iterative manner, stitch each 3D point set to the main view using the point correspondences i.e., finding optimal
% transformation between shared points in your 3D point clouds. 

% Initialize the merged (aligned) cloud with the main view, in the first point set.
mergedCloud                 = zeros(3, size(PV,2));
mergedCloud(:, Clouds{1,3}) = Clouds{1, 2};  
mergedInds                  = Clouds{1,3}; 
mergedIndsCell{1,1}         = mergedInds;

% Stitch each 3D point set to the main view using procrustes
numClouds = size(Clouds,1);
cloudNumberCounter = 0;
for i = 2:numClouds

    % Get the points that are in the merged cloud and the new cloud by using "intersect" over indexes
    [sharedInds, ~, iClouds] = intersect(mergedInds, Clouds{i,3});
    sharedPoints             = Clouds{i,2}(:,iClouds);

    % A certain number of shared points to do procrustes analysis.
    if size(sharedPoints, 2) < 15
        cloudNumber(i-cloudNumberCounter) = [];
        cloudNumberCounter = cloudNumberCounter + 1;
        continue
    end

    % Find optimal transformation between shared points using procrustes. The inputs must be of the size [Nx3].
    [~, ~, T] = procrustes(mergedCloud(:,sharedInds)', sharedPoints'); 

    % Find the points that are not shared between the merged cloud and the Clouds{i,:} using "setdiff" over indexes
    [iNew, iCloudsNew] = setdiff(Clouds{i,3}, mergedInds);

    % T.c is a repeated 3D offset, so resample it to have the correct size
    c = T.c(ones(size(iCloudsNew,1),1),:);

    % Transform the new points using: Z = (T.b * Y' * T.T + c)'.
    % Note: We transposed the inputs to "procrustes" so we also have to transpose the input/output to the transformation. 	 
    % And then we store them in the merged cloud, and add their indexes to mergedInds set. 
    mergedCloud(:, iNew) = (T.b * Clouds{i,2}(:,iCloudsNew)' * T.T + c)';
    mergedInds           = [mergedInds Clouds{i,3}(iCloudsNew)];
    mergedIndsCell{1,cloudNumber(i)}  = Clouds{i,3}(iCloudsNew);
end
mergedCloud = mergedCloud(:, find(all(mergedCloud~=0,1)));
mergedIndsCell = mergedIndsCell(~cellfun('isempty',mergedIndsCell));

% Plot of the full merged cloud
X_plot = mergedCloud(1,:)';
Y_plot = mergedCloud(2,:)';
Z_plot = mergedCloud(3,:)';
scatter3(X_plot, Y_plot, Z_plot, 20, [1 0 0], 'filled');
axis( [-500 500 -500 500 -500 500] )
daspect([1 1 1])
rotate3d

%% PART 6 - 3D Visualization
disp('PART 6 - 3D Visualization');
disp(' ');

% Surface Rendering
surfaceRender(mergedCloud, M1, MeanFrame1, im2double(imread(strcat(directory, Files(1).name))));

% Assigne RGB color to each point
images_cell = {};
for i = 1:1:nImages
    im = imread([Files(i).folder '\' Files(i).name]);
    images_cell{i} = im;
end
ptc_rgb = getRGBvalue(images_cell, cloudNumber, mergedIndsCell, PV, C, numFrames);
ptc_rgb_uint8 = uint8(ptc_rgb)';

figure
points3D = [X_plot Y_plot Z_plot];
ptCloud = pointCloud(points3D, 'C', ptc_rgb_uint8);
pcshow(ptCloud,'MarkerSize',400)