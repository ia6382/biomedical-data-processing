function [idx] = QRSDetect(fileName)
    m = 7;
    LPFWidth = 38; %according to article has to be 150ms long 38
    decisionWindowWidth = 150;
    minDistance = 50;
    alfa = 0.05;
    gama = 0.2; %0.15

    %load data
    S = load(fileName);
    S1 = S.val(1,1:3500);
    S2 = S.val(2,1:3500);

    %%%%
    % Linear High-Pass Filter
    %%%%
    %m point moving average filter
    a = [1 -1];
    b = (1/m)*[1,zeros(1,m-1),-1];
    %freqz(b,a)
    y1 = filter(b,a,S2);

    %delay filter
    a = 1;
    b = [zeros(1, (m+1)/2 - 1), 1];
    y2 = filter(b,a,S2);

    %HPF output
    y = y2 - y1;
    yH = y;
    %%%%
    % Nonlinear Low-Pass Filter
    %%%%
    %amplification
    y = y.^2;

    %sliding window sumation
    a = 1;
    b = ones(1, LPFWidth);
    y = filter(b,a,y);

    %%%%
    % Decision making stage
    %%%%
    %find treshold value
    %treshold = 5e3;
    tresholds = zeros(1,15);
    i = 1;
    for j=1:15
        [val, ~] = max(y(i:i+decisionWindowWidth));
        tresholds(j) = val;
        i = i+decisionWindowWidth;
    end
    treshold = mean(tresholds);
    
    idx = zeros(1, size(y,2));
    vals = zeros(1, size(y,2));
    prevPeak = 1;


    i = 1;
    while i < size(y,2)-decisionWindowWidth
        [val, indx] = max(y(i:i+decisionWindowWidth));
        d = i+indx - prevPeak; %distance between peaks

        if val > treshold && d > minDistance
            tresholdNew = gama*val;
            treshold = alfa*tresholdNew + (1-alfa)*treshold;
            idx(i) = i+indx;
            vals(i) = treshold;
            prevPeak = i+indx;
        end

        i = i+decisionWindowWidth;
    end

    idx = nonzeros(idx)';
    vals = nonzeros(vals)';

    %plot signals
    sigX = 1:size(S1, 2); % vector for x-axis (in samples)
    hold on;
    subplot(3,1,1);
    plot(sigX, S2);
    subplot(3,1,2);
    plot(sigX, yH); 
    subplot(3,1,3);
    plot(sigX, y);
    hold on;
    scatter(idx, vals);
    hold off;
end