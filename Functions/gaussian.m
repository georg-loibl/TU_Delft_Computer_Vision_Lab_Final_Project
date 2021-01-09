function G = gaussian(sigma)

z = ceil(3*sigma);
x = -z:1:z;

% Calculate filter
G = 1/(sigma*sqrt(2*pi))*exp(-x.^2/(2*sigma^2));

% Normalize filter
G = G/sum(G);

end