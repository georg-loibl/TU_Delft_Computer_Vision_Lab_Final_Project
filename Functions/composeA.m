% function A = composeA(x1, x2)
% Compose matrix A, given matched points (X1,X2) from two images
% Input: 
%   -normalized points: X1 and X2 
% Output: 
%   -matrix A
function A = composeA(x1, x2)
    A = zeros(size(x1,2),9);
    
    for i = 1:size(x1,2) 
        x = x1(1,i);
        y = x1(2,i);
        x_p = x2(1,i);
        y_p  = x2(2,i);
        A(i,:) = [x*x_p, x*y_p, x, y*x_p, y*y_p, y, x_p, y_p, 1];   
    end
end
