%{
    Necla Nur Akalın    2171148
    Ayşenur Bülbül      2171403
%}

clear;
clc;

%% Reading images %%
A1 = imread('CENG466_THE3_Part1/A1.png');
A2 = imread('CENG466_THE3_Part1/A2.png');
A3 = imread('CENG466_THE3_Part1/A3.png');
A4 = imread('CENG466_THE3_Part1/A4.png');
A5 = imread('CENG466_THE3_Part1/A5.png');
A6 = imread('CENG466_THE3_Part1/A6.png');



%% Getting the sizes of images %%
A1_height = size(A1,1);
A1_width = size(A1,2);
A2_height = size(A2,1);
A2_width = size(A2,2);
A3_height = size(A3,1);
A3_width = size(A3,2);
A4_height = size(A4,1);
A4_width = size(A4,2);
A5_height = size(A5,1);
A5_width = size(A5,2);
A6_height = size(A6,1);
A6_width = size(A6,2);



%% Transforming to grayscale %%
A1_gray = rgb2gray(A1);
A2_gray = rgb2gray(A2);
A3_gray = rgb2gray(A3);
A4_gray = rgb2gray(A4);
A5_gray = rgb2gray(A5);
A6_gray = rgb2gray(A6);



%% Creating binary images %%
A1_binary = zeros(A1_height, A1_width, 'logical');
A2_binary = zeros(A2_height, A2_width, 'logical');
A3_binary = zeros(A3_height, A3_width, 'logical');
A4_binary = zeros(A4_height, A4_width, 'logical');
A5_binary = zeros(A5_height, A5_width, 'logical');
A6_binary = zeros(A6_height, A6_width, 'logical');



%% Thresholding A1 %%

for y=1:A1_height
    for x=1:A1_width
        if (A1_gray(y,x) > 70)
            A1_binary(y, x) = 0;
        else
            A1_binary(y, x) = 1;
        end
    end
end
SE = strel('disk', 3);
A1_binary = imclose(A1_binary, SE);



%% Thresholding A2 %%

for y=1:int16(A2_height/2)
    for x=1:A2_height
        if (A2_gray(y,x) > 77)
            A2_binary(y, x) = 0;
        else
            A2_binary(y, x) = 1;
        end
    end
end
for y=int16(A2_height/2):A2_height
    for x=1:A2_width
        if (A2_gray(y,x) < 86 || A2_gray(y,x) > 89)
            A2_binary(y, x) = 0;
        else
            A2_binary(y, x) = 1;
        end
    end
end
A2_binary = bwmorph(A2_binary,'spur', 5);
A2_binary = bwmorph(A2_binary,'clean', 3);
A2_binary = bwmorph(A2_binary,'thicken', 20);
SE = strel('disk', 13);
A2_binary = imclose(A2_binary, SE);



%% Thresholding A3 %%

for y=1:A3_height
    for x=1:A3_width
        if (A3_gray(y,x) > 65)
            A3_binary(y, x) = 0;
        else
            A3_binary(y, x) = 1;
        end
    end
end
SE = strel('disk', 2);
A3_binary = imclose(A3_binary, SE);
A3_binary = bwmorph(A3_binary,'spur', 5);
A3_binary = bwmorph(A3_binary,'clean', 3);



%% Thresholding A4 %%

for y=1:A4_height
    for x=1:A4_width
        if (A4_gray(y,x) > 45 && A4_gray(y, x) < 246)
            A4_binary(y, x) = 0;
        else
            A4_binary(y, x) = 1;
        end
    end
end
A4_binary = bwmorph(A4_binary,'bridge');
A4_binary = bwmorph(A4_binary,'spur');
A4_binary = bwmorph(A4_binary,'thicken');

%% Thresholding A5 %%

for y=1:A5_height
    for x=1:A5_width
        if ((A5_gray(y,x) > 85 && A5_gray(y,x) < 255))
            A5_binary(y, x) = 0;
        else
            A5_binary(y, x) = 1;
        end
    end
end
SE = strel('disk', 3);
A5_binary = imopen(A5_binary, SE);
SE = strel('disk',25);
A5_result = imclose(A5_binary,SE);

%% Thresholding A6 %%

for y=1:A6_height
    for x=1:A6_width
        if ((A6_gray(y,x) > 15))
            A6_binary(y, x) = 0;
        else
            A6_binary(y, x) = 1;
        end
    end
end
SE = strel('disk',3);
A6_binary = imopen(A6_binary, SE);
SE = strel('disk',25);
A6_result = imclose(A6_binary,SE);
[A6_result, ~] = bwlabel(A6_result);
A6_result = deleteComp(A6_result, 2);


%% Labelling components %%

[A1_result, ~] = bwlabel(A1_binary);
[A1_result, A1_n] = bwlabel(A1_result);

[A2_result, ~] = bwlabel(A2_binary);
[A2_result, A2_n] = bwlabel(A2_result);

[A3_result, ~] = bwlabel(A3_binary);
[A3_result, A3_n] = bwlabel(A3_result);

[A4_result, ~] = bwlabel(A4_binary);
[A4_result, A4_n] = bwlabel(A4_result);

[A5_result, ~] = bwlabel(A5_result);
[A5_result, A5_n] = bwlabel(A5_result);

[A6_result, ~] = bwlabel(A6_result);
[A6_result, A6_n] = bwlabel(A6_result);

%% Printing %%

imwrite(A1_result, 'part1_A1.png');
fprintf('The number of flying jets in image A1 is %d\n', A1_n);

imwrite(A2_result, 'part1_A2.png');
fprintf('The number of flying jets in image A2 is %d\n', A2_n);

imwrite(A3_result, 'part1_A3.png');
fprintf('The number of flying jets in image A3 is %d\n', A3_n);

imwrite(A4_result, 'part1_A4.png');
fprintf('The number of flying jets in image A4 is %d\n', A4_n);

imwrite(A5_result, 'part1_A5.png');
fprintf('The number of flying jets in image A5 is %d\n', A5_n);

imwrite(A6_result, 'part1_A6.png');
fprintf('The number of flying jets in image A6 is %d\n', A6_n);