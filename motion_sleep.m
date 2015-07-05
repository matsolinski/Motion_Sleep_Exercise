%-----------------------------
%--- MOTION & SLEEP - EXERCISE
%-----------------------------
%--- MATEUSZ SOLINSKI --------
%-----------------------------

%-----------------------------
%  LOAD DATA

%---- phone.csv

fid = fopen('phone.csv');
out = textscan(fid,'%s%f%f%f','delimiter',',');
fclose(fid);

timestamp = out{1};
Xacc = out{2};
Yacc = out{3};
Zacc = out{4};

%---- sleep_phases.csv

fid = fopen('sleep_phases.csv');
out = textscan(fid,'%s%f','delimiter',',');
fclose(fid);

timestampSP = out{1};
sleepP = out{2};


%----- create motion vector


absInstMot = sqrt(Xacc(1:end).^2 + Yacc(1:end).^2 + Zacc(1:end).^2 );
motionVect =  abs(diff(absInstMot));
figure(3)
  plot(motionVect)

  %alternative version
%absInstMot = sqrt( (Xacc(2:end)-Xacc(1:end-1)).^2 + (Yacc(2:end)-Yacc(1:end-1)).^2 + (Zacc(2:end)-Zacc(1:end-1)).^2 );
%motionVect =  absInstMot;
%figure(2)
%  plot(motionVect)

%----- print
show=0;
if(show)
  figure(1)
    subplot(4,1,1)
      plot(Xacc);
      title('Accelerometer X-axis');
    subplot(4,1,2)
      plot(Yacc)
      title('Accelerometer Y-axis');
    subplot(4,1,3)
      plot(Zacc)
      title('Accelerometer Z-axis');
    subplot(4,1,4)
      plot(sleepP)
      title('Sleep Phases');  
end