G2 = z_gen(3,:) + z_gen(4,:) + z_gen(63,:);
G6 = z_gen(5,:) + z_gen(6,:);
G_ext = sum(z_gen, 1) - G2 - G6;
G_ext = G_ext - G_ext(1);
G_total = G2 + G6 + G_ext;
T = 1800;
t = size(G2, 2);
delta = T - t;

%% passive
saet = SAET(1);

G2 = [G2(1)*ones(1, saet) G2];
G6 = [G6(1)*ones(1, saet) G6];
G_ext = [G_ext(1)*ones(1, saet) G_ext];
G_total = [G_total(1)*ones(1, saet) G_total];

G2 = [G2 G2(end)*ones(1, delta)];
G6 = [G6 G6(end)*ones(1, delta)];
G_ext = [G_ext G_ext(end)*ones(1, delta)];
G_total = [G_total G_total(end)*ones(1, delta)];

G2 = G2(1:T);
G6 = G6(1:T);
G_ext = G_ext(1:T);
G_total = G_total(1:T);

%% proactive
% G2 = [G2 G2(end)*ones(1, delta)];
% G6 = [G6 G6(end)*ones(1, delta)];
% G_ext = [G_ext G_ext(end)*ones(1, delta)];
% G_total = [G_total G_total(end)*ones(1, delta)];

%% plot
plot((1:T)/60, G2, 'Color','#0072BD', 'LineWidth', 1.5)
hold on
box off
plot((1:T)/60, G6, 'LineWidth', 1.5)
plot((1:T)/60, G_ext, 'LineWidth', 1.5)
T_sam = 0.25:0.25:30;
G_total_sam = G_total(T_sam * 60);
plot([0 T_sam], [G_total(1) G_total_sam], '*')
% xlabel('time / min')
% ylabel('power generation / MW')
set(gca,'FontSize',16,'LineWidth',2, 'Xtick', 0:5:15)
set(gcf,'unit','centimeters','position',[3 5 11 12])
% legend('{\itP}_{XS}', '{\itP}_{HZ}', '\Delta{\itP}_{others}', '{\itP}_{XS} + {\itP}_{HZ} + \Delta{\itP}_{others}', 'Orientation','horizon', 'box', 'off')
xlim([0, 15])
ylim([0, 2000])


tpos=find(G_total_sam<=1722.5);
TT=[T_sam(tpos(1):tpos(end)),T_sam(tpos(end):-1:tpos(1))];
YY=[G_total_sam(tpos(1):tpos(end)),1722.5*ones(1,31)];
fill(TT,YY,[0.9,0.9,0.9],'LineStyle','--');
