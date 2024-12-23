function F = depox(im, mask, blur_strength, batch_size)
    if ~exist('blur_strength', 'var')
        blur_strength = 20;
    end
    if ~exist('batch_size', 'var')
        batch_size = 30;
    end
    

    kernel_isolated_points = [-1 -1 -1; -1 8 -1; -1 -1 -1];
    basic_pox = abs(double(imfilter(im2gray(im2double(im)), kernel_isolated_points)) .* mask);
    basic_pox = rescale(basic_pox, 0, 1);

    kernel_has_neighbour = ones(batch_size);
    pox_grown = imfilter(basic_pox, kernel_has_neighbour);
    pox_grown = rescale(pox_grown, 0, 1);

    gaussined = imgaussfilt(im2double(im), blur_strength);
    F = gaussined .* pox_grown + im2double(im) .* (1 - pox_grown);
end