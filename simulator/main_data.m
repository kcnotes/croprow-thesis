clear all; close all; clc;

pathToCamera = fileparts(which('camera_store.py'))

if count(py.sys.path, pathToCamera) == 0
    insert(py.sys.path, int32(0), pathToCamera);
end

% set(gcf,'Color','w');
% set(gca, 'FontName', 'Times New Roman');

global showFigures;
showFigures = 0; 

sliceRange = [0 2];

% Camera faces towards positive y angled down a bit
    thetaX = deg2rad(0);
    thetaY = deg2rad(0);
    thetaZ = deg2rad(90); % rand(1)*(60) - 30 + 90
rotateX = [[1 0 0]; [0 cos(thetaX) -sin(thetaX)]; [0 sin(thetaX) cos(thetaX)]];
rotateY = [[cos(thetaY) 0 sin(thetaY)]; [0 1 0]; [-sin(thetaY) 0 cos(thetaY)]];
rotateZ = [[cos(thetaZ) -sin(thetaZ) 0]; [sin(thetaZ) cos(thetaZ) 0]; [0 0 1]];
% rotateX * rotateY;

% for camMove = -2:0.1:2
% disp(strcat("camMove:", num2str(camMove)));
% cam = Camera([camMove*0.05 -3+camMove 3], rotateX * rotateY * rotateZ);
cam = Camera([0 -6 1], rotateX * rotateY * rotateZ);

% Create figure
if (showFigures)
    f = figure(1); clf;
    axis([-5 5 -5 5 -1 10]);
        hold on;
        grid on;
    h = plot3(0,0,0);
    h2 = title('Dataset 5, timestamp: ');
    h_h = text(2, -4, 'Hough: ');
    h_r = text(2, -4.5, 'RANSAC: ');
    h_e = text(2, -5, 'Expected: ');
    ray_h = Ray(cam.Origin, [0 0 0]);
    ray_r = Ray(cam.Origin, [0 0 0]);
    h_hl = ray_h.plotObject('r');
    h_rl = ray_r.plotObject('b');
    view([0 90]);
end

drawnow

tic
mod = py.importlib.import_module('camera_store');
py.importlib.reload(mod);

files = dir(fullfile(strcat(pathToCamera, '\data\dataset5'), '*.log'));

for k = 1:length(files)
    tic
    fileName = files(k).name;
    % fileName = '20200417_18-16-48.708474.log';
    disp("Currently showing " + fileName);
    tic
    pyOut = cell(py.camera_store.read_and_process("data/dataset5/" + fileName(1:end-4)));
    newData = zeros(cam.ImageHeight * cam.ImageWidth, 1);
    for n=1:numel(pyOut)
        newData(n) = double(pyOut{n});
    end
    toc 
    tic
    cam.fromDistances(newData * 0.005);
    
    toc
    
    xlabel('x');
    ylabel('y');
    zlabel('z');

    % figure(2); clf;
    % axis([-5 5 -5 5 -1 5]);
    hold on; grid on;
    xlabel('x');
    ylabel('y');
    zlabel('z');
    % indexes = find(cam.Points(:,3) > 0.5 & cam.Points(:,3) < 2);
    
    showFigures = 0;
    tic
    anglesHough = performHough(cam.Points, sliceRange, 5);
    disp("Hough elapsed time: " + toc + " seconds.");
    
    tic
    anglesRANSAC = performRANSAC(cam.Points, sliceRange, 3);
    disp("RANSAC elapsed time: " + toc + " seconds.");
    
    showFigures = 0;
    if (showFigures)
        delete(h);
        delete(h2);
        delete(h_h);
        delete(h_r);
        delete(h_e);
        delete(h_hl);
        delete(h_rl);
        ii = find(cam.Points(:,3) > 0 & cam.Points(:,3) < 2);
        h = plot3(cam.Points(ii,1), cam.Points(ii,2), cam.Points(ii,3), 'k.');
        h2 = title(strcat("Dataset 5, timestamp: ", fileName(end-18:end-4)));
        h_h = text(2, -4, "Hough: " + anglesHough(1), 'Color', 'r');
        h_r = text(2, -4.4, "RANSAC: " + -anglesRANSAC(1), 'Color', 'b');
        ray_h = Ray(cam.Origin, [sin(deg2rad(anglesHough(1))) cos(deg2rad(anglesHough(1))) 2]);
        ray_r = Ray(cam.Origin, [sin(deg2rad(-anglesRANSAC(1))) cos(deg2rad(-anglesRANSAC(1))) 2]);
        h_e = text(2, -4.8, 'Expected: N/A');
        h_hl = ray_h.plotObject('r');
        h_rl = ray_r.plotObject('b');
    end
    cam.Points = zeros(cam.ImageHeight, cam.ImageWidth, 3);
    
    drawnow
    disp("----");
end
% end