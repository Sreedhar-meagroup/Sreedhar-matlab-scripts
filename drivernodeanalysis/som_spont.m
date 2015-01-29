net = selforgmap([8,8]);
data = sbro.Ranklist;
net = train(net,data');
view(net)
y = net(x);
classes = vec2ind(y);
