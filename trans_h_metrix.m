function [tforms] = trans_h_metrix(I1, I2)
    % Calculate the two image transformation matrices using SIFT

    % Convert images to grayscale
    img1_gray = single(rgb2gray(I1));  % Convert to single precision for VLFeat
    img2_gray = single(rgb2gray(I2));

    % Detect SIFT features (using VLFeat)
    [f1, d1] = vl_sift(img1_gray, 'Levels', 2, 'Edgethresh', 10);
    [f2, d2] = vl_sift(img2_gray, 'Levels', 2, 'Edgethresh', 10);

    % Match the features based on descriptors
    matches = vl_ubcmatch(d1, d2);  % matches stores the indices of the matching features

    % Get the matched points' coordinates
    img1_points = f1(1:2, matches(1, :));  % x, y coordinates of matched points in image 1
    img2_points = f2(1:2, matches(2, :));  % x, y coordinates of matched points in image 2

    % Find the transformation matrix using matched points
    tforms = estimateGeometricTransform(...
        img1_points', img2_points', 'projective', ...
        'Confidence', 99.9, 'MaxNumTrials', 5000, 'MaxDistance', 3);

    % Visualize the matched features (optional)
    % figure;
    % showMatchedFeatures(I1, I2, img1_points', img2_points', 'montage');
    % title('Matched Points');
end
