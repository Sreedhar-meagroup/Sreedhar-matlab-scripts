net = selforgmap([4,4]);
data = sbro.Ranklist;
net = train(net,data);
view(net)
y = net(data);
classes = vec2ind(y);
