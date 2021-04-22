clearvars,
close all,
clc,

im1 = imread('1.jpg');
im2 = imread('2.jpg');
im3 = imread('3.jpg');
im4 = imread('4.jpg');

load('pt1')
load('pt2')
load('pt3')
load('pt4')

% 4 punts per la homografia

figure(1),imshow(im1)
zoom on;  
pause();
zoom off;
[x1, y1] = ginput(4);
zoom out;
save('pt1', 'x1', 'y1');

% els 4 corresponents a l'altra imatge
figure(2),imshow(im2)
zoom on;  
pause();
zoom off;
[x2, y2] = ginput(4);
zoom out;
save('pt2', 'x2', 'y2');

% els 4 corresponents a l'altra imatge
figure(3),imshow(im3)
zoom on;  
pause();
zoom off;
[x3, y3] = ginput(4);
zoom out;
save('pt3', 'x3', 'y3');

% els 4 corresponents a l'altra imatge
figure(4),imshow(im4)
zoom on;  
pause();
zoom off;
[x4, y4] = ginput(4);
zoom out;
save('pt4', 'x4', 'y4');




%SEGONA IMG
M = [];
for i=1:4
    M = [  M ;
        x1(i)  y1(i)  1   0       0        0   -x2(i)*x1(i)   -x2(i)*y1(i) -x2(i);
         0       0    0   x1(i)   y1(i)    1   -y2(i)*x1(i)   -y2(i)*y1(i) -y2(i)];
end
[u,s,v] = svd( M );
H = reshape( v(:,end), 3, 3 )';
H = H / H(3,3);

tf = projective2d(inv(H'));
marc = imref2d(size(im1)); %marco de referencia
out_img_2 = imwarp(im2, tf , 'OutputView', marc);
figure(1),imshow(im1)
figure(2),imshow(out_img_2)


%TERCERA IMG
M = [];
for i=1:4
    M = [  M ;
        x1(i)  y1(i)  1   0       0        0   -x3(i)*x1(i)   -x3(i)*y1(i) -x3(i);
         0       0    0   x1(i)   y1(i)    1   -y3(i)*x1(i)   -y3(i)*y1(i) -y3(i)];
end
[u,s,v] = svd( M );
H = reshape( v(:,end), 3, 3 )';
H = H / H(3,3);

tf = projective2d(inv(H'));
marc = imref2d(size(im1)); %marco de referencia
out_img_3 = imwarp(im3, tf , 'OutputView', marc);
figure(3),imshow(out_img_3)

%QUARTA IMG
M = [];
for i=1:4
    M = [  M ;
        x1(i)  y1(i)  1   0       0        0   -x4(i)*x1(i)   -x4(i)*y1(i) -x4(i);
         0       0    0   x1(i)   y1(i)    1   -y4(i)*x1(i)   -y4(i)*y1(i) -y4(i)];
end
[u,s,v] = svd( M );
H = reshape( v(:,end), 3, 3 )';
H = H / H(3,3);

tf = projective2d(inv(H'));
out_img_4 = imwarp(im4, tf , 'OutputView', marc);
figure(4),imshow(out_img_4)

array4D = cat(4,im1, out_img_2, out_img_3, out_img_4);
median_img = median(array4D, 4);
figure(5),imshow(median_img)





%%
path = './images';
% carregem les imatges images.
dataset = imageDatastore(path);
im1 = readimage(dataset,4);
%  llegim la primera imatge del dataset
I = readimage(dataset,4);

% inicialitzem els "features" de la primera imatge
grayImage = im2gray(I);
points = detectSURFFeatures(grayImage); %obtenim els punts dinteres de limatge
[features, points] = extractFeatures(grayImage,points);

n_imgs = numel(dataset.Files);
tforms(n_imgs) = projective2d(eye(3));

% Initialize variable to hold image sizes.
mida_img = zeros(n_imgs,2);

% iterem per totes les imatges que falten
for n = 2:n_imgs

    % ens guardem els punts de la imatge anterior
    points_Anteriors = points;
    features_Anteriors = features;

    % llegim l'imatge d'aquesta iteració
    I = readimage(dataset, n);
    grayImage = im2gray(I);    
    mida_img(n,:) = size(grayImage);    % ens guardem la mida de les imatges

    % detectar i extreure les "SURF features" per l'imatge d'aquesta iteracio
    points = detectSURFFeatures(grayImage);    
    [features, points] = extractFeatures(grayImage, points);

    % RELACIONAR i trobar les CORRESPONDENCIAS entre l'imatge actual i de la iteracio anterior.
    parelles_imgs = matchFeatures(features, features_Anteriors, 'Unique', true);

    Points_relacionats = points(parelles_imgs(:,1), :);
    Points_relacionats_anteriors = points_Anteriors(parelles_imgs(:,2), :);       
    figure; ax = axes;
    showMatchedFeatures(I,readimage(dataset,1),Points_relacionats,Points_relacionats_anteriors, 'montage', 'Parent', ax);
    title(ax, 'Punts coincidents candidats');
    legend(ax, 'Punts coincidents 1','Punts coincidents 2');


    % estimacio de la transformacio entre imatge actual i anterior.
    tforms(n) = estimateGeometricTransform2D(Points_relacionats, Points_relacionats_anteriors,...
        'projective', 'Confidence', 99.9, 'MaxNumTrials', 2000);

    % aconseguim el tform multiplicant a cada iteracio actualitant amb
    % limatge actual
    tforms(n).T = tforms(n).T * tforms(n-1).T; %transformacions relatives a la primera imatge 
end

marc = imref2d(size(im1)); %marco de referencia

out_img = zeros(size(im1, 1), size(im1,2),size(im1,3), 4);
for n = 2:n_imgs
    out_img(:,:,:,n) = imwarp(readimage(dataset, n), tforms(n), 'OutputView', marc);
    figure(n),imshow(out_img(:,:,:,n));
end

array4D = cat(4,im1, out_img(:,:,:,2), out_img(:,:,:,3), out_img(:,:,:,4));
median_img = median(array4D, 4);
figure(5),imshow(median_img)
    
%%





























load('pt1')
load('pt2')
%load('pt3')

%{
% 4 punts per la homografia
figure(1),imshow(im1)
zoom on;  
pause();
zoom off;
[x1, y1] = ginput(4);
zoom out;
save('pt1', 'x1', 'y1');

% els 4 corresponents a l'altra imatge
figure(2),imshow(im2)
zoom on;  
pause();
zoom off;
[x2, y2] = ginput(4);
zoom out;
save('pt2', 'x2', 'y2');
%}

%SEGONA IMG
% DLT (Direct Linear Transformation, sense normalitzar)
M = [];
for i=1:4
    M = [  M ;
        x1(i)  y1(i)  1   0       0        0   -x2(i)*x1(i)   -x2(i)*y1(i) -x2(i);
         0       0    0   x1(i)   y1(i)    1   -y2(i)*x1(i)   -y2(i)*y1(i) -y2(i)];
end
[u,s,v] = svd( M );
H = reshape( v(:,end), 3, 3 )';
H = H / H(3,3);
% fi DLT

tf = projective2d(inv(H'));
marc = imref2d(size(im1)); %marco de referencia
out_img_2 = imwarp(im2, tf , 'OutputView', marc);
figure(1),imshow(im1)
figure(2),imshow(out_img_2)


array3d = cat(2, im2, im1, im3);

figure(3),imshow(array3d)



