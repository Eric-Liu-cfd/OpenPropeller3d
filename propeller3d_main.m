% 输出二维叶型
clear; clc;
close all
load('CRF_geo.mat')
x = gridcenterxcell{1,1}(:,:,1);
y = gridcenterycell{1,1}(:,:,1);
z = gridcenterzcell{1,1}(:,:,1);

[a,airfoil_number] = size(x);

for i = 1:a
    for j = 1:airfoil_number
        line{j} = [x(:,j) y(:,j) z(:,j)];
%         hold on
%         plot3(x(:,j),y(:,j),z(:,j),'b')
    end
end
% 旋转叶片至与z轴垂直
% 用二维投影近似代替三维叶型，并做归一化
for j = 1:airfoil_number
    
    XYZold = [line{1,j}(:,1) line{1,j}(:,2) line{1,j}(:,3)]';
    rad = -0.4;
    u = [0;0;1];
    x0 = [0;0;0];
    % [XYZ, terminal2, terminal3] = AxelRot([geo{i,5}(:,k,j)';geo{i,6}(:,k,j)';geo{i,7}(:,k,j)'],geo{i,4}*t,geo{i,3},geo{i,2});%被旋转坐标，旋转角度，旋转轴，旋转轴原点
    [XYZnew, terminal_R, terminal_t] = AxelRot(XYZold, rad, u, x0); %被旋转坐标，旋转角度，旋转轴，旋转轴原点
    line_new{1,j} = XYZnew';
%     plot3(XYZnew(1,:),XYZnew(2,:),XYZnew(3,:),'r')
    
end
% xlabel('x')
% ylabel('y')
% zlabel('z')
% axis equal
% hold off
%% 
omega = 8000; % 转速
v_axial = 20; % 轴向来流速度
P0 = 101325; % 工作大气压
h = 10;      % 工作海拔
%%
for j = 1:airfoil_number

    Xnew = line_new{1,j}(:,1);
    Ynew = line_new{1,j}(:,2);
    Znew = line_new{1,j}(:,3);
    [attackangle, velocity, naca_dim1, naca_dim2, airfoil_chord]=AirfoilNormalize(Xnew,Ynew,Znew,omega,v_axial);
    AttackAngle(j) = attackangle;
    Velocity(j) = velocity;
    Airfoil_chord(j) = airfoil_chord;
    naca_X{j} = naca_dim1;
    naca_Y{j} = naca_dim2;
end

%% 翼型旋转到水平方向，朝向左边，吸力面在上，压力面在下
for airfoil_num = 1:airfoil_number
        X=[naca_X{airfoil_num}(end);naca_X{airfoil_num}];
        Y=[naca_Y{airfoil_num}(end);naca_Y{airfoil_num}];
        figure(1)
        plot(X,Y,'b')
        hold on
        axis equal
        vec_x = [0,1]; %
        vec_airfoil = [X(round(end/2)),Y(round(end/2))]-[X(1),Y(1)];
        theta_rot = acos(dot(vec_x,vec_airfoil)/(norm(vec_x)*norm(vec_airfoil)))*180/pi;    %弧度制,转角度制乘180/pi

        X0 = X(round(end/2)); Y0 = Y(round(end/2));
        for i = 1:max(size(X))
            [X_rot,Y_rot]=Dim2d_Rrotate(X(i),Y(i),X0,Y0,(theta_rot+90));
            X_Rot(i) = X_rot;
            Y_Rot(i) = Y_rot;
        end

        X_Airfoil = ((X_Rot - X(round(end/2)))'); 
        Y_Airfoil = ((Y_Rot - Y(round(end/2)))'); 

        X_Airfoil = X_Airfoil(2:end-2);
        Y_Airfoil = Y_Airfoil(2:end-2);

        plot(X_Airfoil,Y_Airfoil,'r')

    %% 生成xfoil翼型文件
%     for airfoil_num = 1

        airfoil_name=['r',num2str(airfoil_num),'.dat'];
        fid=fopen(airfoil_name,'wt');
        fprintf(fid,'%s',['r',num2str(airfoil_num),'.dat']);
        fprintf(fid,'\n');
        [point_num,terminal] = size(X_Airfoil);
        for i = 1:point_num
            fprintf(fid,'%10.5f %10.5f',X_Airfoil(i),Y_Airfoil(i));
            fprintf(fid,'\n');
        end
        fclose(fid);
%     end
    %% 调用airfoil计算
%     P0 = 101325;
%     h = 10;

    viscosity = 0.0000178;
    k = 1.4; R = 287;  
    P = P0 * exp( -1.256*10^(-4) * h);
    T = 18 - 6 * h / 1000 + 273.15;

    density = 1.293 * (P/101325) * (273.15/T);
    RE = density * Airfoil_chord(airfoil_num) * Velocity(airfoil_num) / viscosity;
    MACH = Velocity(airfoil_num)/sqrt(k*R*T);
    alpha=AttackAngle(airfoil_num);
    %%
%     for airfoil_num = 1
        airfoil_name=['xfoil_input',num2str(airfoil_num),'.txt'];
        fid=fopen(airfoil_name,'wt');
        fprintf(fid,'load\n');
        fprintf(fid,'%s',['..\PANEL\r',num2str(airfoil_num),'.dat']);
        fprintf(fid,'\n');
        fprintf(fid,'%s',['..\PANEL\r',num2str(airfoil_num),'.dat']);
        fprintf(fid,'\n');
        fprintf(fid,'%s','oper');
        fprintf(fid,'\n');
        fprintf(fid,'%s','iter');
        fprintf(fid,'\n');
        fprintf(fid,'%s',[num2str(1000)]);
        fprintf(fid,'\n');
        fprintf(fid,'%s','vpar');
        fprintf(fid,'\n');
        fprintf(fid,'%s','n');
        fprintf(fid,'\n');    
        fprintf(fid,'%s','1');
        fprintf(fid,'\n');    
        fprintf(fid,'\n'); 

        fprintf(fid,'%s','visc');
        fprintf(fid,'\n');    
        fprintf(fid,'%s','re');
        fprintf(fid,'\n');    
        fprintf(fid,'%s',num2str(RE));
        fprintf(fid,'\n');  
        fprintf(fid,'%s','mach');
        fprintf(fid,'\n');    
        fprintf(fid,'%s',num2str(MACH));
        fprintf(fid,'\n');    

        fprintf(fid,'%s','pacc');
        fprintf(fid,'\n');  
        fprintf(fid,'%s',['YX',num2str(airfoil_num),'.txt']);
        fprintf(fid,'\n'); 
        fprintf(fid,'\n'); 

        fprintf(fid,'%s','alfa');
        fprintf(fid,'\n');  

        fprintf(fid,'%s',num2str(alpha));
        fprintf(fid,'\n');    
        fprintf(fid,'%s','cpwr');
        fprintf(fid,'\n');    
        fprintf(fid,'%s',['Save_Cp_r',num2str(airfoil_num),'.txt']);

        fclose(fid);
%     end

    %% Parameters definition
    cmd=sprintf(['xfoil<xfoil_input',num2str(airfoil_num),'.txt']);
    [status,result]=system(cmd);

end

%% 处理压力系数Cp并做图
for airfoil_num = 1:airfoil_number
    path = ['..\PANEL\Save_Cp_r',num2str(airfoil_num),'.txt'];
    fid = fopen(path,'r');
    for i=1:3
        line=fgetl(fid);
    end
    
    x_read = []; 
    y_read = []; 
    Cp_read = [];
    
    while ~feof(fid)
        str_read = fgetl(fid);
        disp(str_read)
%         num_read = regexp(str_read, '.*?(\d+(\.\d+)*)', 'tokens' ); %s是含有数字的字符串
        num_read = regexp(str_read, '\-?\d*\.?\d*', 'match' ); %s是含有数字的字符串
        x_read =  [x_read;  str2num(num_read{1})];
        y_read =  [y_read;  str2num(num_read{2})];
        Cp_read = [Cp_read; str2num(num_read{3})];
    end
    
        x_out{airfoil_num} = x_read;
        y_out{airfoil_num} = y_read;
        Cp_out{airfoil_num} = Cp_read;
        
        figure(2)
        plot(x_out{airfoil_num},Cp_out{airfoil_num},'b')
        set(gca,'ydir','reverse')
        hold on
end
figure(3)
plot(x_out{round(airfoil_number/2)},(1/2*1.225*power(65,2)*Cp_out{round(airfoil_number/2)}),'b')


fclose all
