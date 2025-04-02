% 压力修正
clear;clc
close all
open('50%pressure.fig');
lh = findall(gca, 'type', 'line');% 如果图中有多条曲线，lh为一个数组
xc = get(lh, 'xdata');            % 取出x轴数据，xc是一个元胞数组
yc = get(lh, 'ydata');            % 取出y轴数据，yc是一个元胞数组

%如果想取得第2条曲线的x，y坐标
x1=xc{1};
y1=yc{1};

%如果想取得第2条曲线的x，y坐标
x2=xc{2};
y2=yc{2};

density = 1.225;V_far = 67; M_far = 0.6;
[y_c] = Pressure_correct(y2,density,V_far,M_far); % 卡门-钱修正

figure(1)
plot(x1,y1,'r')
hold on
plot(x2,y2,'b')

figure(2)
plot(x1,y1,'r')
hold on
plot(x2,y_c,'b')

figure(3)
plot(x2,y2,'r')
hold on
plot(x2,y_c,'b')

