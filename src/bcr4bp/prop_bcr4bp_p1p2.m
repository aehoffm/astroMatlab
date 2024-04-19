function [traj_out,varargout] = prop_bcr4bp_p1p2(traj_in,options,prop)
varargout{1} = NaN; %{1}
traj_out = traj_in;
sysModel = traj_in.system_model;
tspan = traj_in.getTimeSpan();
tspan = tspan.change_unit('nd_t',sysModel);
tspan = tspan.value;
r0 = traj_in.getInitPos();
r0 = r0.change_unit('nd_l',sysModel);
r0 = r0.value;
v0 = traj_in.getInitVel();
v0 = v0.change_unit('nd_v',sysModel);
v0 = v0.value;
spacecraft = traj_in.low_thrust.spacecraft;
mass0 = traj_in.getInitMass();
mass0 = mass0.change_unit('nd_m',spacecraft);
mass0 = mass0.value;
mu3 = sysModel.char.mu.value;
m4 = sysModel.char.massP4.value;
a4 = sysModel.char.distP4.value;
descNodeP4 = sysModel.char.descNodeP4.value;
incP4 = sysModel.char.incP4.value;
theta0P4 = sysModel.char.theta0P4.value;
nP4 = sqrt((1+m4)/a4^3); %should also be able to just call sysModel.angVelP4+1
Tmax = spacecraft.TmaxND.value;
Isp = spacecraft.IspND.value;
g0 = spacecraft.g0ND.value;
cLaw = traj_in.low_thrust.control_law;
throttle = spacecraft.throttle;
Tmax = Tmax*throttle;
switch prop
    case 'manual'
        STM_0 = eye(7);
        STM_0 = reshape(STM_0,49,1);
        dsdepoch_0 = zeros(6,1);
        [tout, stateVec] = ode113(@(t,s) BCR4BPdiffeq_LT(t,s,tspan(1),...
            m4,a4,descNodeP4,incP4,theta0P4,nP4,Tmax,Isp,g0,cLaw),tspan,...
            [r0; v0; mass0; STM_0; dsdepoch_0],options);
        stateVec = transpose(stateVec);
        STM_f = stateVec(8:56,end);
        STM_f = reshape(STM_f,7,7);
        dsdepoch_f = stateVec(57:62,end);
        stateVec = stateVec(1:7,:);
        STM_f = [STM_f, [dsdepoch_f;nan]]; %append to STM (STM-like term)
    case 'atd'
        error('atd with low-thrust not implemented')
    otherwise
        error('bad propagator method')
end
thrustDir = zeros(3,length(tout));
for i = 1:length(tout)
    [~, uhat] = BCR4BPdiffeq_LT(tout(i),[stateVec(1:7,i); zeros(49,1); zeros(6,1)],...
        tspan(1),m4,a4,descNodeP4,incP4,theta0P4,nP4,Tmax,Isp,g0,cLaw);
    thrustDir(:,i) = uhat;
end
traj_out.low_thrust.thrust_dir_history = thrustDir;
traj_out.time = c_dim_quant(tout,'nd_t');
traj_out.pos = c_dim_quant(stateVec(1:3,:),'nd_l');
traj_out.vel = c_dim_quant(stateVec(4:6,:),'nd_v');
traj_out.low_thrust.mass = c_dim_quant(stateVec(7,:),'nd_m');
STMkey = {'x', 'y', 'z', 'xd', 'yd', 'zd', 'mass', 't0'};
traj_out.stm = c_stm(STM_f,STMkey);
varargout = {varargout};
%% Nested Functions for sharing variables
% ----------------------------------------------------
    function [dsSTMdt, uhat] = BCR4BPdiffeq_LT(t,s_STM,t0,m4,a4,descNodeP4,incP4,theta0P4,nP4,Tmax,Isp,g0,controlLaw)
        s = s_STM(1:7);
        STM = s_STM(8:56);
        
        dsdt = zeros(7,1);
        
        dsdt(1:3) = s(4:6);
        [xdd, ydd, zdd, A21, acc_LT, uhat, sP1, sP2, sP4, dsd_dr1,...
            dsd_dr2, dsd_dr4] = eom_bcr4bp_p1p2(s,mu3,t,t0,m4,a4,...
            descNodeP4,incP4,theta0P4,nP4,Tmax,controlLaw,true);
        dsdt(4) = xdd;
        dsdt(5) = ydd;
        dsdt(6) = zdd;
        dsdt(7) = -Tmax/Isp/g0;

        % propagate STM with the new state
         % dSTM(t1) = A(t1)*STM(t1,t0)
        A22 = [0 2 0; -2 0 0; 0 0 0];
        A23 = -acc_LT/s(7); %3x1
        A = [zeros(3,3), eye(3), zeros(3,1);...
            A21, A22, A23;...
            zeros(1,7)]; %7x7 matrix
        STM = reshape(STM,[7 7]);
        dSTMdt = A*STM;
        dSTMdt = reshape(dSTMdt,[49 1]);

        %dsdepoch calculation
        dsdepoch = s_STM(57:62); %57:end
        vP1 = sP1(4:6);
        vP2 = sP2(4:6);
        vP4 = sP4(4:6);
        d_dsdepoch_dt = A(1:6,1:6)*dsdepoch + dsd_dr1*vP1 + dsd_dr2*vP2 + dsd_dr4*vP4;
        
        %put it all together
        dsSTMdt = [dsdt;dSTMdt;d_dsdepoch_dt];
    end
% ----------------------------------------------------
end