function [tforms] = trans(I1,I2)
    % Calculate the two image transformation matrices

    % Conversion to grayscale
    img1_gray = rgb2gray(I1);
    img2_gray = rgb2gray(I2);

    % Detect SIFT features
    img1_point = vl_sift(img1_gray);
    img2_point = vl_sift(img2_gray);

    % Extracting point-of-interest descriptors
    [img1_features, img1_point] = extractFeatures(img1_gray,img1_point);
    [img2_features, img2_point] = extractFeatures(img2_gray,img2_point);

    % Matching feature points
    indexPairs = matchFeatures(img1_features, img2_features,'MaxRatio',0.74);
    img1 = img1_point(indexPairs(:,1), :);
    img2 = img2_point(indexPairs(:,2), :);

    % Find the transformation matrix
    tforms = estimateGeometricTransform(img1, img2,...
            'similarity','Confidence', 98, 'MaxNumTrials', 3000);
        
    % Visualize the matched features (optional)
    figure;
    showMatchedFeatures(I1, I2, img1, img2, 'montage');
    title('Matched Points');
    
end