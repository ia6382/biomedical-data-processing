function  linked = cannyDetect3(filename)
    %treshold parameters
    TM = 0.3
    A = 0
    TA = 180 %45
    K = 0.02 %0.05

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

    %Edge linking
    %local processing
    %treshold for binary image
    TM = TM * max(max(mag));
    g = uint8(mag>TM & ang>=A-TA & ang<=A+TA);
    %figure; imshow(g, []); title('Binary');

    %horizontal gap fill
    g1 = g;%zeros(m,n);
    for i=1:m
        for j=2:n
           k1 = uint64(min(K*n,n-j));
           if g(i,j-1) == 1 && g(i,j) == 0
              %fill gap if smaller than k1
              gap = g(i,j:j+k1-1);
              l = 0;
              for k =1:size(gap,2)
                if gap(k) == 1
                    break
                end
                l = l + 1;
              end
              if l < k1
                  g1(i,j:j+l-1) = ones(1, l);
              end
           end
        end
    end
    %figure; imshow(g1, []); title('hFill');

    %vertical gap fill
    gr = imrotate(g,90);
    g2 = gr;%zeros(n,m);
    for i=1:n
        for j=2:m
           k2 = uint64(min(K*m,m-j));
           if gr(i,j-1) == 1 && gr(i,j) == 0
              %fill gap if smaller than k1
              gap = gr(i,j:j+k2-1);
              l = 0;
              for k =1:size(gap,2)
                if gap(k) == 1
                    break
                end
                l = l + 1;
              end
              if l < k2
                  g2(i,j:j+l-1) = ones(1, l);
              end
           end
        end
    end
    g2 = imrotate(g2, -90);
    %figure; imshow(g2, []); title('vFill');

    %final image
    f = g1 | g2;
    %figure; imshow(f, []); title('Final');

    %morphological thining to 1px lines
    %linked = bwmorph(f,'thin', Inf);

    %morphological boundary extraction
    SE = strel('rectangle', [double(int32(m*0.005)), double(int32(n*0.005))]);
    linked = f - imerode(f, SE);
    linked = bwmorph(linked,'thin', Inf);
    %figure; imshow(linked, []); title('linked');
    
    %plot
    figure;
%     montage({image,double(g),linked},'size',[1 NaN]);
    subplot(1,3,1);
    imshow(image, []); title('Original');
    subplot(1,3,2);
    imshow(g, []); title('Binary');
    subplot(1,3,3);
    imshow(linked, []); title('Final');
end