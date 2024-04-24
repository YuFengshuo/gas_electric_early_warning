GT = z_gen([11,20,22,23,24,76,77,60,61,66,67,32,33],:);
GT1 = z_gen(4,:) + z_gen(7,:);
GT2 = z_gen(2,:) + z_gen(13,:);
GT3 = z_gen(103,:) + z_gen(104,:);
GT4 = z_gen(69,:) + z_gen(70,:);
GT5 = z_gen(84,:) + z_gen(87,:);
GT6 = z_gen(45,:) + z_gen(46,:);
GT7 = z_gen(11,:) + z_gen(20,:) + z_gen(22,:);
GT8 = z_gen(23,:) + z_gen(24,:);
GT9 = z_gen(32,:) + z_gen(33,:);
GT10 = z_gen(60,:) + z_gen(61,:);
GT11 = z_gen(76,:) + z_gen(77,:);
GT12 = z_gen(66,:) + z_gen(67,:);
NP1 = z_gen(95,:) + z_gen(96,:);
NP2 = z_gen(97,:) + z_gen(98,:) + z_gen(99,:) + z_gen(100,:) + z_gen(101,:);
ST1 = z_gen(73,:) + z_gen(74,:);
ST2 = z_gen(71,:) + z_gen(72,:);
t = 1/60:1/60:80;
figure(1)
hold on
grid on
plot(t,GT1,'LineWidth',2,'Color',[0.3059    0.4745    0.6549])
plot(t,GT2,'LineWidth',2,'Color',[0.9490    0.5569    0.1686])
plot(t,GT3,'LineWidth',2,'Color',[0.8824    0.3412    0.3490])
plot(t,GT4,'LineWidth',2,'Color',[0.4627    0.7176    0.6980])
plot(t,GT5,'LineWidth',2,'Color',[0.3490    0.6314    0.3098])
plot(t,GT6,'LineWidth',2,'Color',[0.9294    0.7882    0.2824])
plot(t,NP1,'LineWidth',2,'Color',[0.6902    0.4784    0.6314])
plot(t,NP2,'LineWidth',2,'Color',[1.0000    0.6157    0.6549])
plot(t,ST1,'LineWidth',2,'Color',[0.6118    0.4588    0.3725])
plot(t,ST2,'LineWidth',2,'Color',[0.7294    0.6902    0.6745])
legend('GT1','GT2','GT3','GT4','GT5','GT6','NP1','NP2','ST1','ST2')
% legend('GT1+GT2+GT3','GT4+GT5+GT6','NP1','NP2','ST1','ST2')
set(gca,'FontSize',14,'LineWidth',1)
set(gcf,'unit','centimeters','position',[10 10 10 10])
xlim([0, 60])
ylim([0, 3200])
xlabel('time / min')
ylabel('power generation / MW')
figure(2)
hold on
grid on
plot(t,GT7,'LineWidth',2)
plot(t,GT8,'LineWidth',2)
plot(t,GT9,'LineWidth',2)
plot(t,GT10,'LineWidth',2)
plot(t,GT11,'LineWidth',2)
plot(t,GT12,'LineWidth',2)
legend('GT7','GT8','GT9','GT10','GT11','GT12')
set(gca,'FontSize',14,'LineWidth',1)
set(gcf,'unit','centimeters','position',[10 10 10 10])
xlim([0, 60])
ylim([0, 1500])
xlabel('time / min')
ylabel('power generation / MW')

GEN_TOL = [GT1;GT2;GT3;GT4;GT5;GT6;GT7;GT8;GT9;GT10;GT11;GT12;NP1;NP2;ST1;ST2]';
GEN_TOL = GEN_TOL(1:3600,:);