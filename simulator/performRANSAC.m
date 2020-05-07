function angles = performRANSAC(points, sliceRange, repeats)
   global showFigures;
   displayPoints = reshape(points, [], 3);
   displayPoints2 = displayPoints(displayPoints(:,3) > sliceRange(1) & displayPoints(:,3) < sliceRange(2), :);
   displayPoints2 = round(displayPoints2 * 100);
   thetaZ = deg2rad(90);
   rotateZ = [[cos(thetaZ) -sin(thetaZ) 0]; [sin(thetaZ) cos(thetaZ) 0]; [0 0 1]];
   displayPoints2 = displayPoints2 * rotateZ;

   if (showFigures)
      x = displayPoints2(:,1);
      y = displayPoints2(:,2);
      
      figure(5);clf;
      plot(x, y, 'k.');
      axis equal;
      hold on;
   end

   % modelLeastSquares = polyfit(x, y, 1);
   % x = [min(x) max(x)];
   % y = modelLeastSquares(1)*x + modelLeastSquares(2);
   % plot(x,y,'r-');
   
   sampleSize = 2; % number of points to sample per trial
   maxDistance = 200; % max allowable distance for inliers

   % fit function using polyfit
   fitLineFcn = @(points) polyfit(points(:,1),points(:,2),1); 
   % distance evaluation function
   evalLineFcn = @(model, points) sum((points(:, 2) - polyval(model, points(:,1))).^2,2);
   
   angles = [];

   for repeat = 1:repeats
      try
      [modelRANSAC, inlierIdx] = ransac(displayPoints2(:,1:2),fitLineFcn,evalLineFcn, ...
      sampleSize,maxDistance, 'Confidence', 60);
      catch
         angles = [];
         disp("RANSAC estimated angles: " +  num2str(angles(:).'));
         return
      end

      modelInliers = polyfit(displayPoints2(inlierIdx,1),displayPoints2(inlierIdx,2),1);
      
      inlierPts = displayPoints2(inlierIdx,1:2);
      x = [min(inlierPts(:,1)) max(inlierPts(:,1))];
      y = modelInliers(1)*x + modelInliers(2);
      
      if (showFigures)
         disp(length(inlierPts));
         plot(inlierPts(:,1), inlierPts(:,2), 'r.');
         plot(x, y, 'g-');
         camroll(-90);
      end
      displayPoints2 = displayPoints2(~inlierIdx,:);
      angles = [angles rad2deg(atan(modelRANSAC(1)))];
   end
   % disp(angles);
   disp("RANSAC estimated angles: " +  num2str(angles(:).'));
end