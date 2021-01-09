function Gd = gaussianDer(G, sigma)

z = ceil(3*sigma);
x = -z:1:z;

Gd = (-x./sigma^2).*G;

end