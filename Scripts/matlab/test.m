
X = rand(1,20)

figure
hist(X,20)
h = findobj(gca,'Type','patch');
set(h,'FaceColor','r','EdgeColor','w','facealpha',0.75)
hold on

figure
[COUNTSn] =  suavgausiano(X,3)
plot(COUNTSn);