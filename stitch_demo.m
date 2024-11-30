%% Creating a dataset
clear;clc;
img_data = imageDatastore('images');
% Calculate the number of images
num = numel(img_data.Files);

%% find the two most similar graphs
im1 = 1;
im2 = 1;
max_p = 0;
for i=1:num-1
    for j=i+1:num
        
        % load images
        I1 = readimage(img_data,i);
        I2 = readimage(img_data,j);
        p = peak(I1,I2);
        mp = max(max(p));
        
        % Calculate the maximum similarity and record the images
        if mp > max_p
            im1 = i;
            im2 = j; 
            max_p = mp;
        end
    end
    
end

% load the two most similar pictures
I1 = readimage(img_data,im1);
I2 = readimage(img_data,im2);

%% Image alignment for the two most similar images
% Initialize the transformation matrix
t1 = affine2d([1 0 0;0 1 0;0 0 1]);

% Compute the transformation matrix using SURF features
[tforms] = trans(I2,I1);

% Image alignment based on transformation matrix
[image] = stitch_fin(I1,I2,tforms,t1);
figure;imshow(image);

%% Align the remaining images one by one
% Record the number of remaining images
img_list1 = 1:num;
% Record the number of stitched images
img_list2 = [im1,im2];

% Remove the most similar images from the remaining image sequence
img_list1(img_list1==im1) = [];
img_list1(img_list1==im2) = [];
sum_mp = 0;

for i=1:length(img_list1)
    max_sum = 0;
    len_list2 = length(img_list2);
    
    % Calculate the peak sum of the pulse function for each unstitched image
    % and each stitched image.
    for j=1:length(img_list1)
        for k=1:len_list2
            I_ori = readimage(img_data,img_list2(k));
            I = readimage(img_data,img_list1(j));
            p = peak(I_ori,I);
            mp = max(max(p));
            % Record the sum of peaks 
            sum_mp = sum_mp + mp;
        end
        
        if  sum_mp > max_sum
            max_sum = sum_mp;
            sim_img = img_list1(j);
        end
        sum_mp = 0;
    end
    
    % load the most similar picture 
    I1 = readimage(img_data,sim_img);
    
    % Record the transformation matrix of the last transformation
    trans_last = tforms;
    
    % Compute the transformation matrix using SURF features
    [tforms] = trans(I1,image);
    [image] = stitch_fin(image,I1,tforms,trans_last);
    
    % Remove the most similar images from the remaining image sequence 
    img_list2(len_list2+1) = sim_img;
    img_list1(img_list1==sim_img) = []; 
    imshow(image);
end

%% Save image
% It can be seen that the final match works well and is consistent with the
% best stitching order in the paper.
imwrite(image,'stitch1.jpg');
