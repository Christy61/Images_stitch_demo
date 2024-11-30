%% Creating a dataset
clear; clc;
rootDir = 'dataset';
allItems = {'case1', 'case2', 'case3', 'case4', 'case5'};

for case_num = 1:numel(allItems)
    folderName = allItems{case_num};
    img_data = imageDatastore(fullfile(rootDir, folderName));
    num = numel(img_data.Files); % Calculate the number of images
    
    %% Find the two most similar images
    im1 = 1;
    im2 = 1;
    max_p = 0;
    for i = 1:num-1
        for j = i+1:num
            % Load images
            I1 = readimage(img_data, i);
            I2 = readimage(img_data, j);
            sizeI1 = size(I1); % [height, width, channels]
            I2_resized = imresize(I2, [sizeI1(1), sizeI1(2)]);
            p = peak(I1, I2_resized);
            mp = max(max(p));

            % Calculate the maximum similarity and record the images
            if mp > max_p
                im1 = i;
                im2 = j; 
                max_p = mp;
            end
        end
    end

    % Load the two most similar images
    I1 = readimage(img_data, im1);
    I2 = readimage(img_data, im2);

    %% Image alignment for the two most similar images
    % Initialize the transformation matrix
    t1 = affine2d([1 0 0; 0 1 0; 0 0 1]);

    % Compute the transformation matrix using SURF features
    [tforms] = trans_h_metrix(I2, I1);

    % Image alignment based on transformation matrix
    [image] = stitch_fin(I1, I2, tforms, t1);
    figure; imshow(image);

    %% Global Transformation: Apply transformation to all remaining images
    % Store the transformation matrices for all images
    transformations = cell(num, 1);
    transformations{im1} = affine2d([1 0 0; 0 1 0; 0 0 1]); % Set the first image as the reference
    transformations{im2} = tforms; % Transformation of the second image based on the first

    % Apply transformation for the rest of the images
    img_list1 = 1:num;
    img_list2 = [im1, im2];
    sum_mp = 0;

    img_list1(img_list1 == im1) = [];
    img_list1(img_list1 == im2) = [];

    % Iterate over the remaining images
    for i = 1:length(img_list1)
        max_sum = 0;
        len_list2 = length(img_list2);

        % Calculate the peak sum of the pulse function for each unstitched image
        % and each stitched image.
        for j = 1:length(img_list1)
            for k = 1:len_list2
                I_ori = readimage(img_data, img_list2(k));
                I = readimage(img_data, img_list1(j));
                sizeI1 = size(I_ori); % [height, width, channels]
                I_resized = imresize(I, [sizeI1(1), sizeI1(2)]);
                p = peak(I_ori, I_resized);
                mp = max(max(p));
                % Record the sum of peaks 
                sum_mp = sum_mp + mp;
            end

            if sum_mp > max_sum
                max_sum = sum_mp;
                sim_img = img_list1(j);
            end
            sum_mp = 0;
        end

        % Load the most similar image
        I1 = readimage(img_data, sim_img);

        % Compute the transformation matrix for the most similar image
        [tforms] = trans_h_metrix(I1, image);

        % Store the transformation for the current image
        transformations{sim_img} = tforms;

        % Update the stitched image
        [image] = stitch_fin(image, I1, tforms, transformations{img_list2(end)});
        
        % Add the newly stitched image to the list of stitched images
        img_list2(end+1) = sim_img;
        img_list1(img_list1 == sim_img) = [];

        imshow(image);
    end

    %% Save image
    % Save the final stitched image
    mkdir('result/with_h_metrix');
    path = sprintf('result/with_h_metrix/stitch-%s.jpg', folderName);
    imwrite(image, path);
end