function coords2D = fliptransformCyl_NPparab(coords3D)

% create an output matrix of the same size as the input
% first two rows are x and y
% the third row indicates whether the location should be visible
%%
coords2D = coords3D;

% [azimuth,elev,~] = cart2sph(coords3D(1,:),coords3D(2,:),coords3D(3,:));

% hypotxy = hypot(coords3D(1,:),coords3D(2,:));
hypotxy = sqrt(coords3D(1,:).^2 + coords3D(2,:).^2);
% rmaze = hypot(hypotxy,coords3D(3,:));
elev = atan2(coords3D(3,:),hypotxy);
azimuth = atan2(coords3D(2,:),coords3D(1,:));

% visible = ~(azimuth<-pi/4 & azimuth>(-pi + pi/4));
visible = ~(azimuth<0 | azimuth>pi);

xSign = sign(coords3D(1,:));
ySign = sign(coords3D(2,:));
azTemp = abs(azimuth);
azTemp(xSign==-1) = -azTemp(xSign==-1)+pi;

a = -0.125;%-0.035;%-0.125;%-0.1442;
b = -1*tan(azTemp).*ySign;

distFromScreenToMouse = 6;%8; %7

c = distFromScreenToMouse;

%x = ((-b+sqrt(b.^2 - 4.*a.*c))./(2.*a));
% quadratic formula to find the solution to the polynomial describing
% the shape of the screen
x = ((-b-sqrt(b.^2 - 4.*a.*c))./(2.*a));
x = x.*xSign;

% x = max([x; x2]).*xSign;
x(x<-20) = -20;
x(x>20) = 20;

y = a.*x.^2;

% figure out the height on the screen
unknown = 20.6; %16;

proj_dist = -y+unknown;
% screenDist = hypot(x,y+distFromScreenToMouse);
screenDist = sqrt(x.^2 + (y+distFromScreenToMouse).^2);

heightOnScreen = tan(elev).*screenDist;%(coords3D(3,:).*screenDist)./hypotxy;

projectedImageHeight = (proj_dist./1.3).*(9/16);

% unknown = 20.6;

blah = 16/9;
%blah = 20/9;
% denom = 6;

%coords2D(1,:) = -((x.*(unknown./(-y+unknown)))./7.5).*blah;
coords2D(1,:) = ((x.*(unknown./(-y+unknown)))./7.5).*blah;
coords2D(2,:) = 1.*(heightOnScreen./projectedImageHeight);
coords2D(2,coords2D(2,:)<-1) = -1;
%coords2D(1:2,:) = coords2D(1:2,:) * -1; % JG210222 flip x and y for optorig
coords2D(3,:) = visible;