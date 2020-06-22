%{
    Necla Nur Akalın    2171148
    Ayşenur Bülbül      2171403
%}

clear;
clc;

mkdir 'Segmentation_results_algo1'
mkdir 'Segmentation_results_algo2'

sourceDir = 'CENG466_THE3_Part2';

destDir1 = 'Segmentation_results_algo1';
destDir2 = 'Segmentation_results_algo2';

imageFiles = dir(fullfile(sourceDir, '*.jpg'));

for k = 1:numel(imageFiles)
    F = fullfile(sourceDir,imageFiles(k).name);
    image = imread(F);

    algo1_image = segmentation1(image);
    algo2_image = segmentation2(image, 4, rand(4, 1));

    dest1Fullname = fullfile(destDir1,imageFiles(k).name);
    dest2Fullname = fullfile(destDir2,imageFiles(k).name);

    imwrite(algo1_image, dest1Fullname);
    imwrite(algo2_image, dest2Fullname);
end