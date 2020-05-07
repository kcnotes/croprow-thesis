% Class for a Cylinder object in the scene
classdef Cylinder < SceneObject
    properties
        Direction
        RadiusX
        RadiusY
        Width
        RotateAxis
        RotateAngle
    end
    methods
        %% Constructor for a Cylinder
        % @Param origin x,y,z of 
        function cylinder = Cylinder(origin, direction, radiusX, radiusY, width)
            cylinder.Origin = origin;
            cylinder.Direction = direction; % vector to where the cylinder points towards
            cylinder.RadiusX = radiusX;
            cylinder.RadiusY = radiusY;
            cylinder.Width = width;

            % Get angle offset
            zAxis = cylinder.Direction / norm(cylinder.Direction);
            cylinder.RotateAxis = cross(zAxis, [0 0 1])';
            cylinder.RotateAngle = atan2(norm(cylinder.RotateAxis), dot(zAxis, [0 0 1]));

        end
        % Using https://johannesbuchner.github.io/intersection/intersection_line_cylinder.html
        %  TODO: deal with the sides of cylinders
        % https://mrl.nyu.edu/~dzorin/rend05/lecture2.pdf

        function [hit1, hit2] = intersection(cyl, ray)
            % Translate and rotate ray to [0,0,0]
            newRot = rodrigues_rot((ray.Direction)', cyl.RotateAxis, cyl.RotateAngle)';
            newOri = rodrigues_rot((ray.Origin - cyl.Origin)', cyl.RotateAxis, cyl.RotateAngle)';
            tRay = Ray(newOri, newRot);
            k = tRay.Direction(2) / tRay.Direction(1);
            l = tRay.Direction(3) / tRay.Direction(1);
            x0 = tRay.Origin(1);
            y0 = tRay.Origin(2);
            z0 = tRay.Origin(3);
            a2 = cyl.RadiusX^2;
            b2 = cyl.RadiusY^2;
            sqr = a2*b2*(a2*k^2+b2-k^2*x0^2+2*k*x0*y0-y0^2);
            if (sqr < 0)
                hit1 = NaN;
                hit2 = NaN;
            else
                
                hit1 = tRay.Origin + (1/(a2*k^2+b2) * (-a2*k*y0 - b2*x0 + sqrt(sqr)))*[1 k l];
                hit2 = tRay.Origin - (1/(a2*k^2+b2) * (a2*k*y0 + b2*x0 + sqrt(sqr)))*[1 k l];

                if hit1(3) > cyl.Width || hit1(3) < 0
                    hit1 = NaN;
                else
                    hit1 = rodrigues_rot(hit1', cyl.RotateAxis, -cyl.RotateAngle)';
                    hit1 = hit1 + cyl.Origin;
                end
                if hit2(3) > cyl.Width || hit2(3) < 0
                    hit2 = NaN;
                else 
                    hit2 = rodrigues_rot(hit2', cyl.RotateAxis, -cyl.RotateAngle)';
                    hit2 = hit2 + cyl.Origin;
                end
            end
        end

        function plotObject(cyl)
            [x,y,z] = cylinder(cyl.RadiusX);

            % Scale
            z = z * cyl.Width;

            % Rotate
            a = rodrigues_rot([x(1,:);y(1,:);z(1,:)], cyl.RotateAxis, -cyl.RotateAngle);
            b = rodrigues_rot([x(2,:);y(2,:);z(2,:)], cyl.RotateAxis, -cyl.RotateAngle);

            x = [a(1,:);b(1,:)];
            y = [a(2,:);b(2,:)];
            z = [a(3,:);b(3,:)];

            % Translate
            x = x + cyl.Origin(1);
            y = y + cyl.Origin(2);
            z = z + cyl.Origin(3);
            
            mesh(x,y,z);
        end
    end
end