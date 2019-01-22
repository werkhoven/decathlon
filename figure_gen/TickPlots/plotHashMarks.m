function hp = plotHashMarks(tick_x, tick_y, tick_height, tick_color, tick_alpha)

if size(tick_x,2) < size(tick_x,1)
    tick_x = tick_x';
end
if size(tick_y,2) < size(tick_y,1)
    tick_y = tick_y';
end

tick_x = repmat(tick_x,2,1);
tick_y = repmat(tick_y,2,1);
tick_y(1,:) = tick_y(1,:) - tick_height/2;
tick_y(2,:) = tick_y(2,:) + tick_height/2;

hp = patch('Faces',1:size(tick_x,2),...
    'XData',tick_x,'YData',tick_y,'FaceColor','none',...
    'EdgeColor',tick_color,'EdgeAlpha',tick_alpha);