GT1 = z_gen(2,:) + z_gen(13,:);
GT2 = z_gen(45,:) + z_gen(46,:);
GT3 = z_gen(11,:) + z_gen(20,:) + z_gen(22,:);
GT4 = z_gen(32,:) + z_gen(33,:);
NP1 = z_gen(95,:) + z_gen(96,:);
NP2 = z_gen(97,:) + z_gen(98,:) + z_gen(99,:) + z_gen(100,:) + z_gen(101,:);
ST1 = z_gen(69,:) + z_gen(70,:);
ST2 = z_gen(71,:) + z_gen(72,:);
hold on
grid on
t = 1/60:1/60:60;
plot(t,GT1,'LineWidth',2)
plot(t,GT2,'LineWidth',2)
legend('GT1','GT2')
% plot(t,GT3,'LineWidth',2)
% plot(t,GT4,'LineWidth',2)
% legend('GT3','GT4')
% plot(t,NP1,'LineWidth',2)
% plot(t,NP2,'LineWidth',2)
% legend('NP1','NP2')
% plot(t,ST1,'LineWidth',2)
% plot(t,ST2,'LineWidth',2)
% legend('ST1','ST2')
set(gca,'FontSize',14,'LineWidth',1)
set(gcf,'unit','centimeters','position',[10 10 10 10])
xlim([0, 30])
ylim([0, 1500])
xlabel('time / min')
ylabel('power generation / MW')