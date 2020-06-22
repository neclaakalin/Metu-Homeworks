%{
    Necla Nur Akalın    2171148
    Ayşenur Bülbül      2171403
%}

clc;
clear;

% read images
C1 = imread('CENG466_THE3_Part3/C1.jpg');
C2 = imread('CENG466_THE3_Part3/C2.jpg');
C3 = imread('CENG466_THE3_Part3/C3.jpg');
C4 = imread('CENG466_THE3_Part3/C4.jpg');
C5 = imread('CENG466_THE3_Part3/C5.jpg');

% send those images to helper function
C1_result = part3_helper(C1, 3);
C2_result = part3_helper(C2, 1);
C3_result = part3_helper(C3, 1);
C4_result = part3_helper(C4, 1);
C5_result = part3_helper(C5, 2);

% print images
imwrite(C1_result, 'part3_C1.jpg');
imwrite(C2_result, 'part3_C2.jpg');
imwrite(C3_result, 'part3_C3.jpg');
imwrite(C4_result, 'part3_C4.jpg');
imwrite(C5_result, 'part3_C5.jpg');