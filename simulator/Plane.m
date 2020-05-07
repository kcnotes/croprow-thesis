% Class for a Plane object in the scene
classdef Plane < SceneObject
    properties
        Normal
        Width
        Length
        RotateAxis
        RotateAngle
    end
    methods
        function plane = Plane(origin, normal, width, len)
            plane.Origin = origin;
            plane.Normal = normal;
            plane.Width = width;
            plane.Length = len;

            % Get angle offset of normal to a flat plane
            % This is used to calculate the bounds
            zAxis = plane.Normal / norm(plane.Normal);
            plane.RotateAxis = cross(zAxis, [0 0 1])';
            plane.RotateAngle = atan2(norm(plane.RotateAxis), dot(zAxis, [0 0 1]));
        end
        
        function [hit, hit2] = intersection(plane, ray)
            hit2 = NaN;
            t = dot((plane.Origin - ray.Origin), plane.Normal) / dot(ray.Direction, plane.Normal);
            if t <= 0
                hit = NaN;
            else
                hit = ray.Origin + ray.Direction * t;
                
                % Get boundaries as if origin of plane = 0,0,0
                hitOffOrigin = hit - plane.Origin;

                % Rotate the hit point around 0,0,0 and check if within boundary
                hitOffRotated = rodrigues_rot(hitOffOrigin', plane.RotateAxis, plane.RotateAngle)';
                x = hitOffRotated(1);
                y = hitOffRotated(2);
                
                if ((x <= plane.Origin(1) - plane.Width / 2) || (x >= plane.Origin(1) + plane.Width / 2))
                    hit = NaN;
                end
                if ((y <= plane.Origin(3) - plane.Length / 2) || (y >= plane.Origin(3) + plane.Length / 2))
                    hit = NaN;
                end
            end
        end

        function plotObject(plane)
            % d = dot(plane.Origin, plane.Normal);
            
            bottomLeft = plane.Origin + rodrigues_rot([-plane.Width/2 -plane.Length/2 0]', plane.RotateAxis, -plane.RotateAngle)';
            topLeft = plane.Origin + rodrigues_rot([plane.Width/2 -plane.Length/2 0]', plane.RotateAxis, -plane.RotateAngle)';
            bottomRight = plane.Origin + rodrigues_rot([-plane.Width/2 plane.Length/2 0]', plane.RotateAxis, -plane.RotateAngle)';
            topRight = plane.Origin + rodrigues_rot([plane.Width/2 plane.Length/2 0]', plane.RotateAxis, -plane.RotateAngle)';

            % [xx, yy] = ndgrid(bottomLeft(1):0.2:topRight(1), bottomLeft(2):0.2:topRight(2));
            % z = (-plane.Normal(1)*xx-plane.Normal(2)*yy+d)/plane.Normal(3);

            patch([bottomLeft(1) topLeft(1) topRight(1) bottomRight(1) bottomLeft(1)], ...
                [bottomLeft(2) topLeft(2) topRight(2) bottomRight(2) bottomLeft(2)], ...
                [bottomLeft(3) topLeft(3) topRight(3) bottomRight(3) bottomLeft(3)], 'blue');
            
            % [xx, yy] = ndgrid(plane.Origin(1)-plane.Width/2:0.2:plane.Origin(1)+plane.Width/2, plane.Origin(3)-plane.Length/2:0.2:plane.Origin(3)+plane.Length/2);
            % z = (-plane.Normal(1)*xx-plane.Normal(2)*yy+d)/plane.Normal(3);
            % mesh(xx,yy,z);
        end
    end
end