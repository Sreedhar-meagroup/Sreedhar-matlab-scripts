function col=colorcircle(x,y,M,N,varargin)
% colorcircle(x,y,M,N)
% create a colorcycle around the center x,y
%
%
intensity=1;
invert = 0;
pvpmod(varargin);

    centrex=(M+1)/2;
    centrey=(N+1)/2;
    alpha=atan2((x-centrex),(y-centrey));
    %disp(alpha*360/(2*pi()));
    centredist=sqrt((x-centrex)^2+(y-centrey)^2);
    maxcentredist=sqrt((M-centrex)^2+(N-centrey)^2);
    phi1=2*pi()/3;
    phi2=2*pi()*2/3;
    col = ([sin(alpha),sin((alpha+phi1)),sin((alpha+phi2))]+1)/2;
    col=(col/max(col));
    col=sqrt(col*(centredist)/maxcentredist).^intensity;
    if invert
        col = abs(col-1);
    end
%create colormap    
% cm=zeros(64,3); mm=zeros(8); for ii=1:8, for jj=1:8, mm(ii,jj)=ii+(jj-1)*8; cm(ii+(jj-1)*8,:)=colorcircle(ii,jj,8,8); end; end;
% imagesc(mm); colormap(cm)