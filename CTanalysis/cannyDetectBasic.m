function  linked = cannyDetect(filename)
    %treshold parameters
    TH = 0.2 %0.1
    TL = 0.1 %0.05

    %load image
    image = imread('data\'+filename);
    image = im2double(image);
    [m, n] = size(image);

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
    %figure; imshow(strong, []); title('Strong');
    %figure; imshow(weak, []); title('weak');

    %Edge linking
    %simple non propagated 8 connectivity
    linked = zeros(m, n);
    for i=2:m-1
        for j=2:n-1
            if strong(i,j) == 1
                linked(i,j) = 1;
            elseif weak(i,j) == 1 && (strong(i-1,j-1) == 1 || strong(i-1,j) == 1 || strong(i-1,j+1) == 1 || strong(i,j-1) == 1 || strong(i,j+1) == 1 || strong(i+1,j-1) == 1 || strong(i+1,j) == 1 || strong(i+1,j+1) == 1)
            	linked(i,j) = 1;
            end
        end
    end
    %figure; imshow(linked, []); title('Final');
    
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