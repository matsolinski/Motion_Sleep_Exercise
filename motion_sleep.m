%-----------------------------
%--- MOTION & SLEEP - EXERCISE
%-----------------------------
%--- MATEUSZ SOLINSKI --------
%-----------------------------

%-----------------------------
%  LOAD DATA


  
%---- sleep_phases.csv

  fid = fopen('sleep_phases.csv');
      outSP = textscan(fid,'%s%f','delimiter',',');
  fclose(fid);

  timestampSP = outSP{1};
  
%---- phone.csv  
  fid = fopen('phone.csv');
     outMot = textscan(fid,'%s%f%f%f','delimiter',',');
  fclose(fid);
  timestamp = outMot{1};

%----- align
[inxMotionSTART,inxSPSTART] = alignSignals(timestamp,timestampSP,'begin')
[inxMotionEND,inxSPEND] = alignSignals(timestamp,timestampSP,'end')


  sleepP = outSP{2}(inxSPSTART:inxSPEND);

  Xacc = outMot{2}(inxMotionSTART:inxMotionEND);
  Yacc = outMot{3}(inxMotionSTART:inxMotionEND);
  Zacc = outMot{4}(inxMotionSTART:inxMotionEND);
  

%----- create motion vector

  absInstMot = sqrt(Xacc(1:end).^2 + Yacc(1:end).^2 + Zacc(1:end).^2 );
  motionVect =  abs(diff(absInstMot));

%----- print


show=1;
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
     
    
   figure(3)
     plot(motionVect) 
end