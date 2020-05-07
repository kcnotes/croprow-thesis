function angles = performHough(points, sliceRange, peaks)
   global showFigures;
   % figure(3); clf;
   % axis([-5 5 -5 5 -1 5]);
   if (showFigures)
      hold on; grid on;
      xlabel('x');
      ylabel('y');
      zlabel('z');
   end
   displayPoints2 = points(points(:,3) > sliceRange(1) & points(:,3) < sliceRange(2), :);
   displayPoints2 = round(displayPoints2 * 40);

   x = displayPoints2(:,1);
   y = displayPoints2(:,2);
   xmin = min(x(:));
   ymin = min(y(:));
   BW = accumarray([x(:) - xmin + 1, y(:) - ymin + 1], 1);
   BW = rot90(logical(BW));
   
   % [H,T,R] = hough(BW);
   [H,T,R] = hough(BW,'Theta',-90:0.25:89);
   % imshow(H,[],'XData',T,'YData',R,...
               % 'InitialMagnification','fit');
   % xlabel('\theta'), ylabel('\rho');

   P  = houghpeaks(H,peaks);
   x = T(P(:,2)); y = R(P(:,1));
   
   if (showFigures)
      plot(x,y,'s','color','white');
      
      figure(3); clf;
      imshow(imadjust(rescale(H)),'XData',T,'YData',R,...
            'InitialMagnification','fit');
      title('Hough transform');
      xlabel('\theta (degrees)')
      ylabel('\rho')
      axis on
      axis normal 
      hold on
      colormap(gca,hot)
   end
   
   xpeaks = T(P(:,2)); ypeaks = R(P(:,1));
   lines = houghlines(BW,T,R,P,'FillGap',81, 'MinLength',20);
   
   if (showFigures)
      plot(xpeaks,ypeaks,'s','color','blue');
      figure(4); clf;
      se = strel('disk',3);
      dilatedI = imerode(1-BW,se);
      imshow(dilatedI); % show actual BW image
      hold on; axis on;
   end

   max_len = 0;
   angles = [];

   for k = 1:length(lines)
      xy = [lines(k).point1; lines(k).point2];
      if (showFigures)
         plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
      end
      angles = [angles lines(k).theta];

      % Determine the endpoints of the longest line segment
      len = norm(lines(k).point1 - lines(k).point2);
      if ( len > max_len)
         max_len = len;
         xy_long = xy;
      end
   end
   disp("Hough estimated angle: " + num2str(angles(:).'));
end