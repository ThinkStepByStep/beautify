function [F, B] = facial(im, threshold)
    min_size = floor(size(im, 1:2) / 10);
    detector = vision.CascadeObjectDetector('MinSize', min_size);
    B = detector(im);
    center = floor([B(2) + B(4) / 4, B(1) + B(3) / 2]);
    im_ul = rgb2lab(im);

    if nargin < 2
        sag_y = 40;
        sag_x = 30;
        neighbour = im(floor(center(1)-B(4)/sag_y):floor(center(1)+B(4)/sag_y), ...
            floor(center(2)-B(3)/sag_x):floor(center(2)+B(3)/sag_x), :);
        threshold = std2(neighbour);
        fprintf('Adaptive threshold falls to %.2f\n', threshold);
    end

    [~, F] = regionGrowing(im_ul, center, threshold);
end