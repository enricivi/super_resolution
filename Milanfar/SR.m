%% start
clear all; close all; clc;

%% parameters
nimg = 20;
niter = 80;      
scale = 2;       % size(HR) = scale * size(LR)
beta = 1;        
lambda = 0.05;   
alpha = 0.6;     
P = 3;           

dir = '../text-test';
format = '.bmp';
%% loading images
for i = 1:nimg
    y(:,:,i) = double((imread(strcat(dir,'/',int2str(i),format))));  
end
figure; imshow(uint8(y(:,:,1))); title('first image of the sequence');

%% registration
tic
kerDim = round(max(size(y(:,:,1)))*0.05*scale); kerDim = max(kerDim, 2);
[~, blur] = deconvblind(y(:,:,1), fspecial('gaussian', kerDim, 1));

[optimizer, metric] = imregconfig('monomodal');
T(1,1) = affine2d();
fixed = y(:,:,1);
for i = 2:nimg
    T(1,i) = imregtform(y(:,:,i), fixed, 'affine', optimizer, metric);
end
computationTime = toc;
disp(['elapsed time to register parameters: ', num2str(computationTime)]);


%% X0
%  X0 = imresize(y(:,:,1), scale*size(y(:,:,1)), 'nearest');
X0 = imresize(median(y, 3), scale*size(y(:,:,1)), 'bilinear'); %per room2
figure; imshow(uint8(X0)); title('starting point (X0)');

%%  iterations 
X = X0;
flipBlur = flip(flip(blur, 1) , 2);
K = size(y); K = K(3);
outputView = imref2d(size(X0));

i = 1;
tic
while i <= niter
    disp(['iter', ' ', int2str(i), ' of ', int2str(niter)]);
    X1 = X;
    
    ML = zeros(size(X));
    for k = 1:K 
        tmpT = T(1,k).invert.T;
        Twarp = imwarp(X, affine2d(tmpT),'OutputView',outputView);
        ml = conv2(Twarp, blur, 'same');
        [h, w] = size(ml);
        ml = ml(1:scale:h, 1:scale:w);
        ml = ml - y(:,:,k);   
        ml = sign(ml);
        ml = upscale(ml, scale); 
        ml = conv2(ml, flipBlur, 'same');
        ml = imwarp(ml, T(1,k), 'OutputView', outputView);
        ML = ML + ml;
    end
    
    % regularization term
    regularization = zeros(size(X));
    for l = -P:P
        for m = 0:P
            if (m + l) >= 0
                reg = X - imtranslate(imtranslate(X, [0 m]), [l 0]);
                reg = sign(reg);
                reg = reg - imtranslate(imtranslate(reg, [-l 0]), [0 -m]);
                reg = (alpha^(abs(m)+abs(l)))*reg;
                regularization = regularization + reg;
            end
        end
    end
    gradient = ML + lambda*regularization;
    
    % update
    X = X - beta * gradient;
    % --
    norm2 = norm(gradient(:));
    if ( norm2 < 10 )
        disp('  break: norm(gradient(:)) < 10');
        break;
    end
    % --
    i = i + 1;
end
computationTime = toc;
disp(['elapsed time to compute HR image: ', num2str(computationTime)]);
figure; imshow(uint8(X)); title('HR image');