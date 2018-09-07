%tracker simulation
clear all;
close all;

len = 500;
cen = len/2 + 1;
nfrm = 100;

dt = 1;  %time step
dx = 1;  %sample spacing in images

xvec = ((-len/2):(len/2-1))*dx;
yvec = xvec;

[X,Y] = meshgrid(xvec,yvec);

tgt = fspecial('disk',10);
tgt = tgt/max(max(tgt));
[rlentgt,clentgt] = size(tgt);
centgt = round(rlentgt/2);
widtgt = floor(rlentgt/2);

x0 = -200;  %starting location of target, pixels
y0 = -150;
vx = 2;   %velocity, pixels/time step
vy = 3;

img_stack = zeros(len,len,nfrm);
xtrue = zeros(nfrm,1);
ytrue = zeros(nfrm,1);
rtrue = zeros(nfrm,1);
ctrue = zeros(nfrm,1);
for m=1:nfrm
    xtrue(m) = x0 + (m-1)*vx;
    ytrue(m) = y0 + (m-1)*vy;
    
    rloc = cen - ytrue(m);
    cloc = cen + xtrue(m);
    
    rtrue(m) = rloc;
    ctrue(m) = cloc;

    rstart = rloc-widtgt;
    rstop = rloc+widtgt;
    cstart = cloc-widtgt;
    cstop = cloc+widtgt;
    
    img_stack(rstart:rstop,cstart:cstop,m) = tgt;

end;

figure
plot(xtrue,ytrue)
%%
%track target with matched filter
template = tgt;
estrloc = zeros(nfrm,1);
estcloc = zeros(nfrm,1);
estx = zeros(nfrm,1);
esty = zeros(nfrm,1);
corrsize = len + 2*widtgt;  %size of correlation output
corrcen = corrsize/2 + 1;     %center of correlation output
for m=1:nfrm
    
    corr1 = xcorr2(img_stack(:,:,m),tgt);
    tcorr = corr1((corrcen-len/2):(corrcen+len/2-1),(corrcen-len/2):(corrcen+len/2-1));
    [rmax,cmax] = find(tcorr == max(max(tcorr)));
    
    estrloc(m) = rmax;
    estcloc(m) = cmax;
    estx(m) = estcloc(m) - cen;
    esty(m) = cen - estrloc(m);
    
end;

figure
plot(estx,esty)
hold
%%
%make t data noisy and try tracking
std = 0.5;
noise = std*randn(len,len,nfrm);
noisy_img_stack = img_stack + noise;

%track target with matched filter
template = tgt;
estrlocn = zeros(nfrm,1);
estclocn = zeros(nfrm,1);
estxn = zeros(nfrm,1);
estyn = zeros(nfrm,1);
corrsize = len + 2*widtgt;  %size of correlation output
corrcen = corrsize/2 + 1;     %center of correlation output
for m=1:nfrm
    
    corr1 = xcorr2(noisy_img_stack(:,:,m),tgt);
    tcorr = corr1((corrcen-len/2):(corrcen+len/2-1),(corrcen-len/2):(corrcen+len/2-1));
    [rmax,cmax] = find(tcorr == max(max(tcorr)));
    
    estrlocn(m) = rmax;
    estclocn(m) = cmax;
    estxn(m) = estclocn(m) - cen;
    estyn(m) = cen - estrlocn(m);
    
end;

plot(estxn,estyn,'r')
