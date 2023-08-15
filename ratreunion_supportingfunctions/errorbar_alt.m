function h = errorbar_alt(x, y, er, param, param2)
%h = errorbar_alt(x, y, er, param, param2)
%
% alternative errorbar that uses 3 plot lines instead of the messy error lines
%
% to specify the upper vs. lower errorbar, use a 2 x n matrix where the top
% is the lower and the bottom the upper.
%
% nei 9/14
% (mod. 5/17)
% 

if min(size(er)) == 2
   er_l = er(1,:);
   er_u = er(2,:);
else
    er_l = er;
    er_u = er;
end

if nargin < 4
    h{1} = plot(x, y, 'LineWidth', 2);
    hold on    
    h{2} = plot(x,y + er_u, 'LineWidth', 1);
    h{3} = plot(x,y - er_l, 'LineWidth', 1);
elseif nargin == 4
   	h{1} = plot(x, y, param, 'LineWidth', 2);
    hold on
    h{2} = plot(x,y + er_u, param, 'LineWidth', 1);
    h{3} = plot(x,y - er_l, param, 'LineWidth', 1);
elseif nargin == 5
   	h{1} = plot(x, y, param, param2, 'LineWidth', 2);
    hold on
    h{2} = plot(x,y + er_u, param, param2, 'LineWidth', 1);
    h{3} = plot(x,y - er_l, param, param2, 'LineWidth', 1);
end

set(h{2}, 'Color', get(h{1}, 'Color'));
set(h{3}, 'Color', get(h{1}, 'Color'));