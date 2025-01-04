%% FIRST PHASE - ODI OVER THREE DIFFERENT BACKGROUNDS
% Acquisition of the image
clc
close all
clear

m = mobiledev;
cam = camera(m, 'back');

cam.Resolution = '1920x1080';

% image of ODI in a favorable scenario
image = snapshot(cam, 'manual');
imwrite(image, 'imageODI3.jpg');

%% segmentation
clc
close all
clear

images = ["imageODI.jpg", "imageODI2.jpg", "imageODI3.jpg"];

for i = 1: length(images)
    
    % RGB
    image = imread(images(i));
    figure;
    subplot(1,2,1)
    imshow(image)

    % gray
    image_gray = rgb2gray(image);
    subplot(1,2,2)
    imshow(image_gray)

    % binary
    image_bin = imbinarize(image_gray);
    figure;
    subplot(1,2,1)
    imshow(image_bin)
    
    % erosion
    se = strel('square', 8);
    image_erode = imerode(image_bin, se);
    
    % fill eroded image
    image_fill = imfill(image_erode, 'holes');
    subplot(1,2,2)
    imshow(image_fill)
    
    % regions
    [B,L] = bwboundaries(image_fill);
    figure;
    subplot(1,2,1)
    imshow(label2rgb(L,@jet,[0.5,0.5,0.5]));
    
    % regions properties
    caract = regionprops(L, 'Area', 'BoundingBox', 'Centroid', 'PixelList');

    % filtering the regions to find personal ODI
    % parameter: biggest area
    ind = 1;
    area_max = 0;
    for i = 1:length(caract)
        if caract(i).Area > area_max
            area_max = caract(i).Area;
            ind = i;
        end
    end

    subplot(1,2,2)
    imshow(image);
    hold on;
    
    % plotting the original image with the ODI in the bounding box
    xinf = caract(ind).BoundingBox(1);
    yinf = caract(ind).BoundingBox(2);
    dimx = caract(ind).BoundingBox(3);
    dimy = caract(ind).BoundingBox(4);
    y = caract(ind).Centroid(2);
    plot(caract(ind).Centroid(1), caract(ind).Centroid(2), 'x', ...
        'LineWidth', 3, 'Color', 'g');
    rectangle('Position',[xinf yinf dimx dimy],'LineWidth',3, ...
        'EdgeColor','g');
end

%% SECOND PHASE - ODI AND DISTRACTOR
% acquisition of the image
clc
close all
clear

m = mobiledev;
cam = camera(m, 'back');

cam.Resolution = '1920x1080';

% image of ODI in a favorable scenario
image = snapshot(cam, 'manual');
imwrite(image, 'imageODIS.jpg');

%% segmentation
clc
close all
clear

% RGB
image = imread('imageODIS.jpg');
figure;
subplot(1,2,1)
imshow(image)

% gray
image_gray = rgb2gray(image);
subplot(1,2,2)
imshow(image_gray)

% binary
image_bin = imbinarize(image_gray);
figure;
subplot(1,2,1)
imshow(image_bin)

% erosion
se = strel('square', 6);
image_erode = imerode(image_bin, se);

% fill eroded image
image_fill = imfill(image_erode, 'holes');
subplot(1,2,2)
imshow(image_fill)

% regions
[B,L] = bwboundaries(image_fill);
figure;
subplot(1,2,1)
imshow(label2rgb(L,@jet,[0.5,0.5,0.5]));

% regions properties
caract = regionprops(L, 'Area', 'Centroid', 'BoundingBox', ...
                     'Circularity', 'Eccentricity','Solidity','PixelList');

% filtering the regions to find personal ODI 
% parameter: big area + high eccentricity + high circularity
area_max = 0;
for i = 1:length(caract)
    area = caract(i).Area;
    if area > area_max
        area_max = area;
    end
end

ind = 1;
maxprop = 0;
for i = 1:length(caract)
    area = caract(i).Area;
    if area > area_max/10
        eccentricity = caract(i).Eccentricity;
        circularity = caract(i).Circularity;
        prop = eccentricity + circularity;
        if prop > maxprop
            maxprop = prop;
            ind = i;
        end
    end
end

% plotting the original image with the ODI in the bounding box
subplot(1,2,2)
imshow(image);
hold on;
xinf = caract(ind).BoundingBox(1);
yinf = caract(ind).BoundingBox(2);
dimx = caract(ind).BoundingBox(3);
dimy = caract(ind).BoundingBox(4);
y = caract(ind).Centroid(2);
plot(caract(ind).Centroid(1), caract(ind).Centroid(2), 'x', ...
    'LineWidth', 3, 'Color', 'g');
rectangle('Position',[xinf yinf dimx dimy],'LineWidth',3,'EdgeColor','g');
