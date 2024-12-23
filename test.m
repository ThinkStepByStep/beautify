s1 = imread('sample1.jpg');

[F, B] = facial(s1);

subplot(1, 4, 1);
imshow(s1);

subplot(1, 4, 2);
imshow(F);

subplot(1, 4, 3);
depoxed = depox(s1, F);
imshow(depoxed);