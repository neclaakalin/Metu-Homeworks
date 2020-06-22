%{
    Necla Nur Akalın    2171148
    Ayşenur Bülbül      2171403
%}

% K-based Segmentation Algorithm

function [result] = segmentation1(image, k, cs)


gray_image = rgb2gray(image);
gray_image = im2double(gray_image);

height = size(gray_image, 1);
width = size(gray_image, 2);

pcs=cs;

D = zeros(height, width, k);

tsmld = [];
eps = 1.e-5;
cmx = 1;
i = 0; 

while (i < 50 && eps < cmx)

    for c=1:k 
      D(:,:,c) = (gray_image - cs(c)).^2 ;     
    end

    [mv,ML] = min(D,[],3);

    for c=1:k
      I = (ML==c);  
      cs(c) = mean(mean(gray_image(I)));    
    end
    
    cmx = max(abs(cs-pcs));
    pcs = cs;
         
    i = i+1;

    tsmld = [tsmld; sum(mv(:))];

end

colors = hsv(k);
result = colors(ML,:);
result =reshape(result, height, width, 3);

end
 