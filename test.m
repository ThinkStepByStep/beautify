s1 = imread('sample4.jpg');

[F, B] = facial(s1);

subplot(1, 4, 1);
imshow(s1);

subplot(1, 4, 2);
imshow(F);

[depoxed, pox_mask] = depox(im2double(s1), F);
subplot(1, 4, 3);
imshow(im2double(s1) .* pox_mask);

subplot(1, 4, 4);
imshow(depoxed);