clc; clear;close;
%% read the data
 viObj =VideoReader('test1.mp4');
 nframes=1; 
 while hasFrame(viObj)
frames(nframes).cdata = readFrame(viObj);
nframes = nframes+1;
 end
 nframes=nframes-1;
%segment the image for tracking the car
imgf1= frames(1).cdata;
imgfg1=rgb2gray(imgf1);
[tgt rect] = imcrop(imgf1);
tgt=rgb2gray(tgt);
cor = normxcorr2(tgt,imgfg1);

%%
%update the image as the correlation will increase the dimension
[ypeak, xpeak] = find(cor==max(cor(:)));
ysrt = ypeak-size(tgt,1);
xsrt = xpeak-size(tgt,2);
rectmark =[xsrt+1, ysrt+1, size(tgt,2), size(tgt,1)];
imgnew = insertShape(imgf1,'Rectangle',rectmark,'LineWidth',3);

% apply correlation to fid traget in the video
v = VideoWriter('resultsques3.avi')

%add the marker to the video's first frame 
open(v) 
writeVideo(v,imgnew);
%%
utgt=tgt;
% cc = sizeimgf1(2)
cc=size(imgf1,2);
rc=size(imgf1,1);
imgnew1=imgnew;

for i=1:(nframes/2)  
    uimg= frames(i).cdata;
     uimgg =rgb2gray(uimg);
%    utgt= imcrop(uimg,rectmark);
   cor = normxcorr2(utgt,uimgg); 
   [uypeak, uxpeak] = find(cor==max(cor(:)));
   ysrt = uypeak-size(tgt,1);
   xsrt = uxpeak-size(tgt,2);
   rmark = xsrt+1+size(utgt,2)/2;
    cmark = ysrt+1+size(utgt,1)/2;
   rectmark =[xsrt-1, ysrt-1, size(tgt,2), size(tgt,1)];
   imgnew2 = insertShape(uimg,'Rectangle',rectmark,'LineWidth',5,'color','green');
    writeVideo(v,imgnew2);
%      utgt= imcrop(uimgg,rectmark);
    imshow(utgt);
    tgtc = max(1,xsrt+1);
    tgtr = max(1,ysrt+1);  
    tgtce = min(tgtc + size(utgt,2)-1,cc);
    tgtre = min(tgtr + size(utgt,1)-1,rc);
    utgt = uimgg(tgtr:tgtre,tgtc:tgtce);
    
end
close(v);
implay('resultsques3.avi')

