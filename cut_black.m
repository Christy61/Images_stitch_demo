function [img] = cut_black(last)
% Cutting the black in the picture

% Conversion to grayscale
Ig = rgb2gray(last);

black = sum(Ig)==0;
if ~isempty(black)
    Inx = 1:size(Ig,2);
    Inx(black)=[];
    image_cut = last(:,Inx,:);
end

Ig = rgb2gray(image_cut);
Ig = Ig';
black = sum(Ig)==0;

% Find the black border and cut
if ~isempty(black)
    Inx = 1:size(Ig,2);
    Inx(black)=[];
    last = image_cut(Inx,:,:);
end

% Return the cut image
img = last;
end