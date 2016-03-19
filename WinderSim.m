%The purpose of this code is to visually represent the winding pattern
%achieved using a proportional control IO relationship between the motors
%of the Carbon Fiber Winder designed and built at AIAA chapter at UIC
%during 2015-2016.
%Created by Kevin Trevino, Rocketry Projects Manager 2015-2016 at AIAA's 
    %Chapter at UIC, 2016. KevinTrevino05@gmail.com4

%Clean commands
clc;
close all;

%Request input parameters
dm = input('Please enter the outer diameter of the mandrel, dm= ');
lm = input('Please enter the length of the mandrel, lm = ');
dp = input('Please enter the outer diameter of the pully/belt system, dp= ');
theta = input('Please enter winding angle for the tube, theta = ');
k = input('Please enter the distance between each strand of wound tow, k = ');
Step_res = input('Please enter the smallest step resolution, Step_res = ');
%Prompt for desired RPM
RPM = input('Please input the desired RPM for the mandrel, RPM = ');

%Calculate proportional control, K_control
K_control = (((dm*pi)-k)/(dp*pi*tan(theta*(pi/180))));%accounts for the angle between winds, not rel to horizontal
%Display the value of the IO controller
disp('________________________________________________________________________');
disp(['The IO relationship of the proportional controller is K_control = ', num2str(K_control,'%-.7g')]);
disp('________________________________________________________________________');

%Round up proportional controller so that number of steps can be multiplied
K_control_roundup=ceil(K_control*(1/.5))/(1/.5);    %to round to nearest quarter or less, modify this line changing the .5 for desired smallest roundup number
disp(['The new proportional controller rounding up is = ',num2str(K_control_roundup,'%-.7g')]);
theta_roundup = atan(((dm*pi-k)/(K_control_roundup*dp*pi)) )*(180/pi);
disp(['The closest theta that can be obtained using the rounded up controller is = ',num2str(theta_roundup,'%-.7g'), ' deg']);

%Round down proportional controller so that number of steps can be
%multiplied and solve for the new theta
K_control_rounddown=floor(K_control*(1/.5))/(1/.5); %to round to nearest quarter or less, modify this line changing the .5 for desired smallest roundup number
disp(['The new proportional controller rounding down is = ',num2str(K_control_rounddown,'%-.7g')]);
theta_rounddown = atan(((dm*pi-k)/(K_control_rounddown*dp*pi)))*(180/pi);
disp(['The closest theta that can be obtained using the rounded down controller is = ',num2str(theta_rounddown,'%-.7g'), ' deg']);

%Prompt choice between the two options for the controller to be used in
%plots later
x = input('Please input which choice controller is desired ( roundup = 1, roundown = 2): ');
i= 0; %flow control functional
K_control_eff=0; %placeholder for final effective controller value to be used
if x == 0 || x>2
    disp('An invalid value has been input. Please choose from given values.');
else 
    switch x,
        case 1 
            K_control_eff = K_control_roundup;
            disp('__________________________________');
            disp(['The controller of choice is: ',num2str(K_control_eff,'%-.7g')]);
            disp('__________________________________');
        case 2
            K_control_eff = K_control_rounddown;
            disp('__________________________________');
            disp(['The controller of choice is: ',num2str(K_control_eff,'%-.7g')]);
            disp('__________________________________');
    end;
end;

%200 steps in each revolution, find d(steps)/dt. Find an integer rate of
%change for ease of integration to Arduino Microcontroller
dsteps_dt = RPM*(200/60);
disp(['The required step/sec rate is: ',num2str(dsteps_dt,'%-.7g')]);
dsteps_dt_eff = floor(dsteps_dt*(1/Step_res))/(1/Step_res);
RPM_eff = dsteps_dt_eff *(60/200);
disp('________________________________________');
disp(['The effective RPM is: ', num2str(RPM_eff,'%-.7g')]);
disp(['The effective step/sec rate is: ',num2str(dsteps_dt_eff,'%-.7g')]);
disp('________________________________________');

%Report of rotational velocities for each motor as well as linear

%velocities for each DOF of interest before plot
%Motor 1 or Mandrel Motor
disp('Information for motor 1 or Mandrel Motor');
disp('_____________________________________________________________________');
w_m1_step = dsteps_dt_eff;              %omega in terms of steps/sec
w_m1_deg = dsteps_dt_eff*(1.8);     %omega in terms of deg/sec
v_m1 = w_m1_deg*(pi/180)*(dm/2);        %linear velocity mandrel
%Display above information
disp(['Omega in terms of step/sec: w_m1_steps = ', num2str((w_m1_step),'%-.7g'), ' step/sec']);
disp(['Omega in terms of deg/sec: w_m1_deg = ', num2str((w_m1_deg),'%-.7g'), ' deg/sec']);
disp(['Linear velocity of the mandrel in unitLength/sec: v_m1 = ', num2str(v_m1,'%-.7g'), ' unitLength/sec']);
disp('_____________________________________________________________________');

%Motor 2 or Linear Motion Motor
disp('Information for motor 2 or linear Motion Motor');
disp('_____________________________________________________________________');
w_m2_step = K_control_eff*w_m1_step;    %omega in terms of steps/sec
w_m2_deg = K_control_eff*w_m1_deg;      %omega in terms of deg/sec
v_m2 = w_m2_deg*(pi/180)*(dp/2);        %linear velocity LMM
%Display above information
disp(['Omega in terms of step/sec: w_m2_steps = ', num2str(w_m2_step,'%-.7g'), ' step/sec']);
disp(['Omega in terms of deg/sec: w_m2_deg = ', num2str(w_m2_deg,'%-.7g'), ' deg/sec']);
disp(['Linear velocity of the LMM in unitLength/sec: v_m2 = ', num2str(v_m2,'%-.7g'), ' unitLength/sec']);
disp('_____________________________________________________________________');

%Begin Plotting
%x = (dm/2)*cos(w_m2_deg*(pi/180)*t);
%y = (dm/2)*sin(w_m2_deg*(pi/180)*t);
%z = t*v_m2;
%syms t;
%ezplot3((dm/2)*cos(w_m2_deg*(pi/180)*t),(dm/2)*sin(w_m2_deg*(pi/180)*t),t*v_m2,[0, (lm/v_m2)]);
%axis equal;