function y = vm_irf(F,J,Omega,H,nv,Omega1)

nshock = size(Omega,2);
y = zeros(H,nv,nshock);

Omega1(1:nv,1:nshock) = Omega;
% COMPUTE IRFs
Ftemp = F^0;

for ii=1:H
    ytemp = J'*(Ftemp)*Omega1;
y(ii,:,:) = ytemp;

    Ftemp = Ftemp*F;
end

end
