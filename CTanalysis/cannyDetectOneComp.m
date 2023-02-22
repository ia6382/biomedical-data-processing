function  linked = cannyDetect2(filename)
    %treshold parameters
    openImage = false
    openMagnitude = false
    TH = 0.2 %0.1
    TL = 0.1 %0.05

    %load image
    image = imread('data\'+filename);
    %image = rgb2gray(image);
    image = im2double(image);
    [m, n] = size(image);

    %morphological opening
    if openImage == true
        SE = strel('rectangle', [5,5]);
        e = imerode(image, SE);
        SE = strel('rectangle', [5,5]);
        image = imdilate(e, SE);
    end

    %smooth image
    fimage = imgaussfilt(image, 2);

    %derivation - gradient
    %Sobel operator
    kx = [-1 0 1; -2 0 2; -1 0 1];
    ky = [-1 -2 -1; 0 0 0; 1 2 1];
    gx = conv2(fimage, kx, 'same');
    gy = conv2(fimage, ky, 'same');

    %magnitude and angle of gradients
    mag = sqrt(gx.^2 + gy.^2);
    ang = atan2d(gy, gx); %in degrees
    %figure; imshow(mag, []); title('Magnitude');

    %morphological opening
    if openMagnitude == true
        SE = strel('rectangle', [5,5]);
        e = imerode(mag, SE);
        SE = strel('rectangle', [5,5]);
        mag = imdilate(e, SE);
        mag = imgaussfilt(mag, 2);
    end

    %Thin the ridges using non-maximum suppression (using magnitude and angle)
    %group angles into one of 4 directions
    ver = uint8(ang >= -22.5 & ang <= 22.5 | ang >= -180 & ang <= -157.5 | ang >= 157.5 & ang <= 180);
    hor = uint8(ang >= -112.5 & ang <= -67.5 | ang >= 67.5 & ang <= 112.5);
    diag1 = uint8(ang >= -157.5 & ang <= -112.5 | ang >= 22.5 & ang <= 67.5);
    diag2 = uint8(ang >= -67.5 & ang <= -22.5 | ang >= 112.5 & ang <= 157.5);

    ang2 = ver*1+hor*2+diag1*3+diag2*4;
    %figure; imshow(ang2, []); title('Angles grouped');

    %supress edges
    thin = mag;
    for i=2:m-1
        for j=2:n-1
            if ang2(i,j) == 1
                if mag(i,j) < mag(i,j-1) || mag(i,j) < mag(i,j+1)
                   thin(i,j) = 0;
                end
            elseif ang2(i,j) == 2
                if mag(i,j) < mag(i-1,j) || mag(i,j) < mag(i+1,j)
                   thin(i,j) = 0;
                end 
            elseif ang2(i,j) == 3
                if mag(i,j) < mag(i-1,j-1) || mag(i,j) < mag(i+1,j+1)
                   thin(i,j) = 0;
                end
            elseif ang2(i,j) == 4
                if mag(i,j) < mag(i+1,j-1) || mag(i,j) < mag(i-1,j+1)
                   thin(i,j) = 0;
                end
            end
        end
    end
    %figure; imshow(thin, []); title('Thined');

    %Double treshold
    TL = TL * max(max(thin));
    TH = TH * max(max(thin));
    strong = uint8(thin>=TH);
    weak = uint8(thin<TH & thin>=TL);

    %Edge linking with one component at a time algorithm
    %https://en.wikipedia.org/wiki/Connected-component_labeling#One_component_at_a_time
    linked = zeros(m, n);
    for i=1:m
        for j=1:n
            %init stack
            ptr = 1;
            stack = [];
            if strong(i,j) == 1 %&& linked(i,j) ~= 1
                linked(i,j) = 1;
                %push
                stack(ptr,:) = [i,j];
                ptr = ptr + 1;
            end
            while ptr > 1
                %pop
                x = stack(ptr-1,1);
                y = stack(ptr-1,2);
                ptr = ptr - 1;
                if ismember(x,[1, m]) || ismember(y,[1, n])
                    continue;
                end
                %check 8 neighbours if weak
                if weak(x-1,y-1) == 1 && linked(x-1,y-1) ~= 1
                    linked(x-1,y-1) = 1;
                    %push
                    stack(ptr,:) = [x-1,y-1];
                    ptr = ptr + 1;
                end
                if weak(x-1,y) == 1 && linked(x-1,y) ~= 1
                    linked(x-1,y) = 1;
                    %push
                    stack(ptr,:) = [x-1,y];
                    ptr = ptr + 1;
                end
                if weak(x-1,y+1) == 1 && linked(x-1,y+1) ~= 1
                    linked(x-1,y+1) = 1;
                    %push
                    stack(ptr,:) = [x-1,y+1];
                    ptr = ptr + 1;
                end
                if weak(x,y-1) == 1 && linked(x,y-1) ~= 1
                    linked(x,y-1) = 1;
                    %push
                    stack(ptr,:) = [x,y-1];
                    ptr = ptr + 1;
                end
                if weak(x,y+1) == 1 && linked(x,y+1) ~= 1
                    linked(x-1,y+1) = 1;
                    %push
                    stack(ptr,:) = [x,y+1];
                    ptr = ptr + 1;
                end
                if weak(x+1,y-1) == 1 && linked(x+1,y-1) ~= 1
                    linked(x+1,y-1) = 1;
                    %push
                    stack(ptr,:) = [x+1,y-1];
                    ptr = ptr + 1;
                end
                if weak(x+1,y) == 1 && linked(x+1,y) ~= 1
                    linked(x+1,y) = 1;
                    %push
                    stack(ptr,:) = [x+1,y];
                    ptr = ptr + 1;
                end
                if weak(x+1,y+1) == 1 && linked(x+1,y+1) ~= 1
                    linked(x+1,y+1) = 1;
                    %push
                    stack(ptr,:) = [x+1,y+1];
                    ptr = ptr + 1;     
                end
            end
        end
    end
    %figure;imshow(linked, []); title('Final');

    %plot
    figure;
%     montage({image,double(strong),linked},'size',[1 NaN]);
    subplot(1,3,1);
    imshow(image, []); title('Original');
    subplot(1,3,2);
    imshow(strong, []); title('Binary');
    subplot(1,3,3);
    imshow(linked, []); title('Final');
end
