function coords2D = calibratedScreen_2p_261009(coords3D)
% calibratedScreen_2p_261009  Screen transformation for the twophoton rig.
%
% Generated 2026-10-09 from a calibration of the physical screen and
% projector. Do not hand-edit: re-run the exporter instead, or the file and
% the calibration will disagree.
%
% Input  coords3D  3xN world coordinates
% Output coords2D  row 1 projector x, row 2 projector y, row 3 visible
%
% Screen is the parabola y = a*x^2 with the animal at (0, -c, 0). The
% projector sits beyond the screen vertex and may be shifted and rotated;
% each point is expressed in the projector's own frame before being divided
% by depth.
%
% Calibrated values:
%   screen        a = -0.124444   half width 7.5000   eye distance 6.5000
%   projector     distance 17.3000   lateral -0.5892   vertical +1.0149
%   rotation      yaw -2.000 deg   tilt +12.500 deg
%   image         x_scale 12.832237   throw ratio 2.396742   aspect 1.777778

a         = -0.124444;
c         = 6.5;
halfW     = 7.5;
H         = 17.3;
xScale    = 12.832237;
throwR    = 2.396742;
aspect    = 1.777777778;
px        = -0.589187;
vOff      = 1.014897;
yawDeg    = -2;
tiltDeg   = 12.5;
marginDeg = 45;
aheadDeg  = 90;

% Steeply downward views (a maze floor right under the animal) put the screen
% point near the projector's lens plane, where depth crosses zero and the
% projection diverges. The renderer draws a triangle if ANY vertex is
% visible, so one diverged vertex drags a filled triangle across the whole
% display. Bounding elevation keeps depth healthy; the screen shows nothing
% near +/-90 deg anyway.
maxElevDeg = 75;

wx = coords3D(1,:);  wy = coords3D(2,:);  wz = coords3D(3,:);

% ---- viewing direction ------------------------------------------------
elev = atan2(wz, sqrt(wx.^2 + wy.^2));
azim = atan2(wy, wx) + (aheadDeg - 90) * pi/180;
azim = atan2(sin(azim), cos(azim));          % wrap into (-pi, pi]
elevLimit = maxElevDeg * pi/180;
elev = min(max(elev, -elevLimit), elevLimit);

% ---- the wedge behind the animal is not drawn -------------------------
margin  = marginDeg * pi/180;
inModel = ~(azim < -margin & azim > -pi + margin);

% ---- intersect the viewing ray with the screen ------------------------
xSign = ones(size(azim));  xSign(cos(azim) < 0) = -1;
ySign = ones(size(azim));  ySign(sin(azim) < 0) = -1;
azT = abs(azim);
azT(xSign < 0) = pi - azT(xSign < 0);

b    = -tan(azT) .* ySign;
disc = b.^2 - 4*a*c;
solvable = disc >= 0;
disc(~solvable) = 0;
xs = (-b - sqrt(disc)) ./ (2*a);
xs = xs .* xSign;

% Clamped, NOT dropped. The renderer draws a triangle if any one of its
% three vertices is visible, and uses the other two vertices' coordinates
% regardless -- so every vertex must carry a finite, sensible position even
% when it is off the screen, or triangles stretch to garbage.
xs = min(max(xs, -halfW), halfW);
ys = a .* xs.^2;
zs = tan(elev) .* sqrt(xs.^2 + (ys + c).^2);

% ---- express in the projector's frame ---------------------------------
yaw  = yawDeg  * pi/180;
tilt = tiltDeg * pi/180;
fwd = [-sin(yaw), -cos(yaw), 0];
rgt = [ cos(yaw), -sin(yaw), 0];
up  = [0, 0, 1];
fwd2 = fwd*cos(tilt) + up*sin(tilt);
up2  = up *cos(tilt) - fwd*sin(tilt);

dx = xs - px;
dy = ys - H;
depth = dx*fwd2(1) + dy*fwd2(2) + zs*fwd2(3);
horiz = dx*rgt(1)  + dy*rgt(2)  + zs*rgt(3);
vert  = dx*up2(1)  + dy*up2(2)  + zs*up2(3);

% The renderer projects with glOrtho(-aspect, aspect, -1, 1): its horizontal
% axis runs to +/-aspect while the vertical runs to +/-1. The model
% normalises both axes to +/-1, so x needs one more factor of aspect here
% and y needs none. Leaving it out shrinks the image horizontally by exactly
% aspect while the height looks right.
ndcX = (horiz .* (H ./ depth) ./ xScale) .* aspect .* aspect;
ndcY = vert .* throwR .* aspect ./ depth + vOff;

visible = inModel & solvable & (depth > 0) & isfinite(ndcX) & isfinite(ndcY);

% A vertex behind the lens or otherwise undefined still has to hold a finite
% number: it may be a corner of a triangle whose other corners are visible.
ndcX(~isfinite(ndcX)) = 0;
ndcY(~isfinite(ndcY)) = 0;

% Row 3 is read as the visibility flag and is then overwritten by the engine
% with each vertex's distance, for depth sorting. Nothing else should go here.
coords2D = coords3D;
coords2D(1,:) = ndcX;
coords2D(2,:) = ndcY;
coords2D(3,:) = visible;
