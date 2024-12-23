function [P, J] = regionGrowing(cIM, initPos, thresVal, maxDist, tfMean, tfFillHoles, tfSimplify)
    if nargin > 7
        error('Wrong number of input arguments!')
    end
    
    cIM = double(cIM);
    
    if ~exist('initPos', 'var') || isempty(initPos)
        himage = findobj('Type', 'image');
        if isempty(himage)
            himage = imshow(cIM, []);
        end
        
        p = ginput(1);
        
        initPos(1) = round(axes2pix(size(cIM, 2), get(himage, 'XData'), p(2)));
        initPos(2) = round(axes2pix(size(cIM, 1), get(himage, 'YData'), p(1)));
    end
    
    if ~exist('thresVal', 'var') || isempty(thresVal)
        thresVal = double((max(cIM(:)) - min(cIM(:)))) * 0.05;
    end
    
    if ~exist('maxDist', 'var') || isempty(maxDist)
        maxDist = Inf;
    end
    
    if ~exist('tfMean', 'var') || isempty(tfMean)
        tfMean = false;
    end
    
    if ~exist('tfFillHoles', 'var')
        tfFillHoles = true;
    end

    [nRow, nCol] = size(cIM, 1:2);
    
    if initPos(1) < 1 || initPos(2) < 1 ||...
       initPos(1) > nRow || initPos(2) > nCol
        error('Initial position out of bounds, please try again!')
    end
    
    if thresVal < 0 || maxDist < 0
        error('Threshold and maximum distance values must be positive!')
    end
    
    if ~isempty(which('dpsimplify.m'))
        if ~exist('tfSimplify', 'var')
            tfSimplify = true;
        end
        simplifyTolerance = 1;
    else
        tfSimplify = false;
    end

    regVal = double(cIM(initPos(1), initPos(2), :));
    
    disp(['RegionGrowing Opening: Initial position (' num2str(initPos(1))...
          '|' num2str(initPos(2)) ') with '...
          num2str(regVal) ' as initial pixel value!'])
    
    J = false(nRow, nCol);
    queue = [initPos(1), initPos(2)];
    
    pSize = size(cIM, 3);
    while size(queue, 1)
        xv = queue(1,1);
        yv = queue(1,2);
        queue(1, :) = [];
        
        for i = -1:1
            for j = -1:1
                if xv+i > 0  &&  xv+i <= nRow &&...          % within the x-bounds?
                   yv+j > 0  &&  yv+j <= nCol &&...          % within the y-bounds?
                   any([i, j])       &&...      % i/j/k of (0/0/0) is redundant!
                   ~J(xv+i, yv+j) &&...          % pixelposition already set?
                   sqrt( (xv+i-initPos(1))^2 +...
                         (yv+j-initPos(2))^2) < maxDist &&...  % within distance?
                   abs(norm(reshape(cIM(xv+i, yv+j, :) - regVal, [pSize 1]))) <= thresVal % within range of the threshold?
        
                   J(xv+i, yv+j) = true;
        
                   queue(end+1,:) = [xv+i, yv+j];
        
                   if tfMean
                       regVal = mean(mean(cIM(J > 0)));
                   end
                end
            end  
        end
    end
    P = [];
    for cSli = 1:1
        if ~any(J(:,:,cSli))
            continue
        end
        
	    % use bwboundaries() to extract the enclosing polygon
        if tfFillHoles
            % fill the holes inside the mask
            J(:,:,cSli) = imfill(J(:,:,cSli), 'holes');    
            B = bwboundaries(J(:,:,cSli), 8, 'noholes');
        else
            B = bwboundaries(J(:,:,cSli));
        end
        
	    newVertices = [B{1}(:,2), B{1}(:,1)];
	    
        % simplify the polygon via Line Simplification
        if tfSimplify
            newVertices = dpsimplify(newVertices, simplifyTolerance);        
        end
        
        % number of new vertices to be added
        nNew = size(newVertices, 1);
        
        P(end+1:end+nNew, :) = newVertices;
    end
end
