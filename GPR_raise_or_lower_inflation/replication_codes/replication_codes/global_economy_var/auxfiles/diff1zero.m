function y = diff1zero(x,indext)


if indext==1
y1 = x(2:end,:,:) - x(1:end-1,:,:) ;
y = [ 0*y1(1:1,:,:) ; y1 ] ;
end


if indext==2
y1 = x(:,2:end) - x(:,1:end-1) ;
y = [ 0*y1(:,1:1) y1 ] ;
end


if indext==3
y1 = x(2:end,:) - x(1:end-1,:) ;
y = [ 0*y1(1:1,:); y1 ] ;
end
