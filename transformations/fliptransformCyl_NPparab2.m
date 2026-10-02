function coords2D = fliptransformCyl_NPparab2(coords3D)
% Cylindrical/parabolic-screen transform for ViRMEn.
% Rows of output: 1 = x, 2 = y, 3 = visibility flag.
%
% Changes vs. original:
%   - visibility cutoff widened to +/-135 deg from straight ahead (margin)
%   - no clamping of y at the bottom edge (OpenGL clips instead)
%   - guard against tan(-pi/2) for points directly below the mouse
%   - projector pose (lateral offset + optional yaw) modelled explicitly,
%     so an off-centre projector is pre-compensated on both sides

coords2D = coords3D;

% ---------------- projector pose: CALIBRATE THESE ----------------
projX   = 0;   % lateral offset of projector lens from the mouse's midline,
               % in the same units as distFromScreenToMouse / unknown.
               % Sign depends on the flip in this rig: if the image gets
               % worse, flip the sign.
projYaw = 0;   % projector yaw in degrees (0 = aimed straight along the
               % midline). Only needed if the projector is angled to
               % point back at the screen centre.
% -----------------------------------------------------------------

hypotxy = sqrt(coords3D(1,:).^2 + coords3D(2,:).^2);
elev    = atan2(coords3D(3,:), hypotxy);
elev    = max(elev, -pi/2 + 1e-3);   % avoid Inf for points straight below
azimuth = atan2(coords3D(2,:), coords3D(1,:));

% visible out to 'margin' behind the lateral line on each side
margin  = pi/4;   % +/-135 deg from straight ahead; don't go much past ~48 deg (fold-back)
visible = ~(azimuth < -margin & azimuth > -pi + margin);

xSign  = sign(coords3D(1,:));
ySign  = sign(coords3D(2,:));
azTemp = abs(azimuth);
azTemp(xSign==-1) = -azTemp(xSign==-1) + pi;

% parabolic screen y = a*x^2, mouse at distance c from the screen vertex
a = -0.125;
b = -1*tan(azTemp).*ySign;
distFromScreenToMouse = 6;
c = distFromScreenToMouse;

% intersection of the viewing ray with the screen (quadratic formula)
x = ((-b - sqrt(b.^2 - 4.*a.*c))./(2.*a));
x = x.*xSign;
x(x < -20) = -20;
x(x >  20) = 20;
y = a.*x.^2;

% projector distance from the screen vertex
unknown = 20.6;

% screen point expressed in the projector's own frame
dx     = x - projX;          % lateral offset from the projector lens
depth  = unknown - y;        % distance along the projector axis (yaw = 0)
dxP    = dx.*cosd(projYaw) - depth.*sind(projYaw);
depthP = dx.*sind(projYaw) + depth.*cosd(projYaw);

% height of the point on the screen, relative to eye level
screenDist     = sqrt(x.^2 + (y + distFromScreenToMouse).^2);
heightOnScreen = tan(elev).*screenDist;

% size of the projected image at that distance from the projector
projectedImageHeight = (depthP./1.3).*(9/16);

blah = 16/9;
coords2D(1,:) = ((dxP.*(unknown./depthP))./7.5).*blah;
coords2D(2,:) = heightOnScreen./projectedImageHeight;
coords2D(3,:) = visible;
