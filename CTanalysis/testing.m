filename = "0001.png";

%compare edge linking
linked1 = cannyDetectBasic(filename);
linked2 = cannyDetectOneComp(filename);
linked3 = cannyDetectLocalProc(filename);

figure;
subplot(1,3,1);
imshow(linked1, []); title('A');
subplot(1,3,2);
imshow(linked2, []); title('B');
subplot(1,3,3);
imshow(linked3, []); title('C');