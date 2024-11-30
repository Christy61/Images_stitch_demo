function [image] = stitch_fin(I1,I2,tforms,tforms_last)
    t1 = affine2d([1 0 0;0 1 0;0 0 1]);

    % Calculate canvas size
    [xlim(1,:), ylim(1,:)] = outputLimits(tforms_last, [1 size(I1,2)], [1 size(I1,1)]); 
    [xlim(2,:), ylim(2,:)] = outputLimits(tforms, [1 size(I2,2)], [1 size(I2,1)]); 
    xMin = min([1;xlim(:)]);
    xMax = max([size(I1,2);xlim(:)]);
    yMin = min([1;ylim(:)]);
    yMax = max([size(I1,1);ylim(:)]);
    width  = round(xMax - xMin);
    height = round(yMax - yMin);
    xLimits = [xMin xMax];
    yLimits = [yMin yMax];

    % Initialize empty canvas
    new = zeros([height width 3], 'like', I2);

    % Create a two-dimensional spatial reference object that defines the size
    % of the panorama.
    view = imref2d([height width],xLimits, yLimits);

    blender = vision.AlphaBlender('Operation', 'Binary mask', ...
        'MaskSource', 'Input port');  

    lastWarpedImage = imwarp(I1,t1,'OutputView', view);
    lastmask = imwarp(true(size(I1,1),size(I1,2)),t1,'OutputView', view);
    warpedImage = imwarp(I2, tforms, 'OutputView', view);
    mask = imwarp(true(size(I2,1),size(I2,2)), tforms, 'OutputView', view);

    % Put the original picture on the canvas
    new = step(blender,new,lastWarpedImage,lastmask);

    % Stitch the images that need to be stitched into the canvas
    image = step(blender,new,warpedImage,mask);

    % Cut the black part of the picture
    image = cut_black(image);

end