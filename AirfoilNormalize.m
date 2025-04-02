% 叶型展开
function[attackangle, velocity, xy_norm, z_norm, chord]=AirfoilNormalize(Xnew,Ynew,Znew,omega,v_axial)

    %% 叶型展开

    x_chord = Xnew; y_chord = Ynew; z_chord = Znew;
    r_airfoil = sqrt(power(x_chord,2)+power(y_chord,2));
    r_chord = sum(sqrt(power(x_chord,2)+power(y_chord,2)))/max(size(Xnew));
    theta_chord = atand(x_chord./y_chord);
    chord = sqrt(power((max(theta_chord)-min(theta_chord))/180*pi*r_chord,2)+power((max(z_chord)-min(z_chord)),2));

    %% 叶型归一化
    xy_norm = theta_chord/180*pi*r_chord/chord - min(theta_chord/180*pi*r_chord/chord);
    z_norm = z_chord/chord;
    % plot(xy_norm,z_norm)
    % axis equal
    geoangle_in = atand((max(z_norm)-min(z_norm))/(max(xy_norm)-min(xy_norm)));

    %% 求来流攻角
    v_rot = 2*pi*omega/60*sum(r_airfoil)/max(size(r_airfoil));
    velocity = sqrt(power(v_axial,2) + power(v_rot,2));
    aeroangle_in = atand(v_axial/v_rot);

    attackangle = geoangle_in - aeroangle_in;
end


