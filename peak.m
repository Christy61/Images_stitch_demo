function [peak] = peak(I1,I2)
% Calculate the similarity of the two images

% Conversion to grayscale
gray_I1 = rgb2gray(I1);
gray_I2 = rgb2gray(I2);

% Perform Fast Fourier Transform
fft_I1 = fft2(gray_I1);
fft_I2 = fft2(gray_I2);

% Find the mutual power according to the equation in the paper
F2_conj = conj(fft_I2);
Formula_3 = F2_conj.*fft_I1./abs(F2_conj.*fft_I1); 

% Return to impulse function
peak = ifft2(Formula_3);

end
