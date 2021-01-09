% function res = residuals(L)
% Returns a matrix containing the residuals computed for every camera view.
% 
% INPUT
%   - L: the matrix L that will be minimized for: Ai L Ai' - Id = 0
%
% OUTPUT
%   - diff: a matrix (n x 4) containing the residuals for the n cameras

function diff = residuals(L)

% Load the saved transformation matrix
M = load('M');
M = M.M;

% Pre-allocate the residuals matrix
diff = zeros(size(M,1)/2,4);

% Compute the residuals
for i = 1:size(M, 1)/2 % Loop over the cameras

    % Define the x and y projections: 
    Ai = M(i*2-1 : i*2, : ); 

    % Definite the function to be minimized: Ai L Ai' - Id = 0
    diff_i = Ai*L*Ai' - eye(size(Ai,1),size(Ai,1));

    diff(i,:) = diff_i(:);
end
