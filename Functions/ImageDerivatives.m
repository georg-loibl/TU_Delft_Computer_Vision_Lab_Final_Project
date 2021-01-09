function F=ImageDerivatives(img , sigma , type)

G = gaussian(sigma); 
z = ceil(3*sigma);
x = -z:1:z;

if (type=="xx" || type=="yy")
  Gdd = (-sigma^2+x.*x)./(sigma^4).*G;
else % 'x','y','xy','yx'
  Gd = gaussianDer(G, sigma); 
end

switch type
    case 'x'
        F = conv2(img, Gd, 'same');     
    case 'y'
        F = conv2(img, Gd', 'same');
    case 'xx'
        F = conv2(img, Gdd, 'same');
    case 'yy'
        F = conv2(img, Gdd', 'same');
    case {'xy', 'yx'}
        F = conv2(Gd, Gd, img, 'same'); 
    otherwise
        error("type should be {x,y,xx,yy,xy,yx}")
end

% imshow(F);
end
