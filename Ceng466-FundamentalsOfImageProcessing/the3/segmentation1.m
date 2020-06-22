%{
    Necla Nur Akalın    2171148
    Ayşenur Bülbül      2171403
%}

% Threshold Based Segmentation Algorithm

function [result] = segmentation1(image)

blackAndWhite = im2bw(image, graythresh(image));
CC = bwconncomp(blackAndWhite);
result = labelmatrix(CC);
result = label2rgb(result);

end