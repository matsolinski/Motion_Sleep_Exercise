%-----------------------------
%--- MOTION & SLEEP - EXERCISE
%-----------------------------
%--- MATEUSZ SOLINSKI --------
%-----------------------------

%-----------------------------

%----  (1) load data
  
  % sleep_phases.csv

  fid = fopen('sleep_phases.csv');
      outSP = textscan(fid,'%s%f','delimiter',',');
  fclose(fid);

  timestampSP = outSP{1};
  sleepPhase = outSP{2};
  
  % phone.csv  
  
  fid = fopen('phone.csv');
     outMot = textscan(fid,'%s%f%f%f','delimiter',',');
  fclose(fid);
  timestamp = outMot{1};
    
  Xacc = outMot{2};
  Yacc = outMot{3};
  Zacc = outMot{4};
  
%----- (2) create motion vector

  absInstMot = sqrt(Xacc(1:end).^2 + Yacc(1:end).^2 + Zacc(1:end).^2 );
  motionVect = abs(diff(absInstMot));
  
  
%----- (3) align
  formatIn = '%Y-%m-%d %H:%M:%S';
  %- get indexes for which the signals are covered each other in time domain
  [inxMotionSTART,inxSPSTART] = alignSignals(timestamp,timestampSP,formatIn,'begin');
  [inxMotionEND,inxSPEND] = alignSignals(timestamp,timestampSP,formatIn,'end');

  % get time in sec for sleep phase signal
  timestampSP=timestampSP(inxSPSTART:inxSPEND);
  SECtimestampSP=zeros(length(timestampSP),1);
  for o=1:length(timestampSP)
    [tm_structSP]=strptime(timestampSP{o}, formatIn);
    SECtimestampSP(o,1)=mktime(tm_structSP);
  end

  % get time in sec for  signal  from accelerometer
  timestampMot=timestamp(inxMotionSTART:inxMotionEND);
  SECtimestampMot=zeros(length(timestampMot),1);
  for o=1:length(SECtimestampMot)
    [tm_structMot]=strptime(timestampMot{o}, formatIn);
    MSEC=str2num(timestampMot{o}(end-2:end));
    tm_structMot.usec=MSEC*1000; %microseconds must had to be added to the struct tm_structMot separately
    SECtimestampMot(o,1)=mktime(tm_structMot);
  end
  
  % create array with aligned signals (sampled according to  timestamp from accelometer signal)
  alignedSig=zeros(length(SECtimestampMot),5);
  
  alignedSig(:,1)=SECtimestampMot; %time in seconds
  alignedSig(:,2)=motionVect(inxMotionSTART:inxMotionEND); %aligned motionVector
  
  o=1;
  %get aligned sleep phase vector
  for i=1:length(SECtimestampMot)
    alignedSig(i,4)=sleepPhase(inxSPSTART+o-1); 
    if(alignedSig(i,1) >= SECtimestampSP(o+1))
      o++;
    end
    if(o==length(SECtimestampSP)) break; end
  end
  
%----- (4) create phase change vector

    alignedSig(:,5)=[0 ; diff(alignedSig(:,4))]!=0;

%----- (5) maximum value of noise

     window=200;
     offset=50;
     motionVectSTD=zeros(floor(length(alignedSig(:,2))/offset)-window,1);
  %find subset of motion vector with the smallest STD (in that subset there are any non-noisy motions)
  len=length(motionVectSTD)
  for  j=1:len
      motionVectSTD(j,1)=std(alignedSig(1 + offset*(j-1) : 1+window + offset*(j-1) ,2));
  end 
  [~,minSTD] = min( motionVectSTD ) %index of the subset of motion vector with the smallest STD
  
  %compute maximum value of noise
  noise=alignedSig(1 + offset*(minSTD-1) : 1+window + offset*(minSTD-1) ,2);

  [thresh,~]=max(noise)
  
%----- (6) motion vector denoising

  alignedSig(:,3)=alignedSig(:,2)>1.1*thresh; %threshold with correction (heuristic)


%----- (7) create vectors of bins

  numberOfIntervals=200;
  numberOfBins=floor(length(alignedSig)/numberOfIntervals);
  
  BinVector=zeros(numberOfBins,2);
  motionBinVector=reshape(alignedSig(1:numberOfBins*numberOfIntervals,3),[numberOfIntervals,numberOfBins]);
  motionBinVectorSum=sum(motionBinVector,1);
  
  sleepchangeBinVector=reshape(alignedSig(1:numberOfBins*numberOfIntervals,5),[numberOfIntervals,numberOfBins]);
  sleepchangeBinVectorSum=sum(sleepchangeBinVector,1);

%----- print

  show=1;
  if(show)

     figure(3)
     subplot(4,1,1)
       plot(alignedSig(:,2)); hold on;
       noiseSTART=1 + offset*(minSTD-1)
       noiseEND=1 + offset*(minSTD-1)+window
       plot([noiseSTART noiseSTART],[0 0.1],'-r', 'markersize',15); hold on; 
       plot([noiseEND noiseEND],[0 0.1],'-r','markersize',15); hold off; 
       title('motion vector')
       xlabel('n')
       ylabel('motion value')
       axis([-inf inf 0 0.2]);
     subplot(4,1,2)
       plot(alignedSig(:,3)); 
       axis([-inf inf 0 1.2]);
       title('motion vector 0-1')
       xlabel('n')
       ylabel('motion change')
     subplot(4,1,3)
       plot(alignedSig(:,4));
       axis([-inf inf 0 6]);
       title('sleep phases')
       xlabel('n')
       ylabel('sleep phase')
     subplot(4,1,4)
       plot(alignedSig(:,5));
       axis([-inf inf 0 1.2]);
       title('sleep phase changes')
       xlabel('n')
       ylabel('sleep phase change')
   

     figure(4)
       bar(motionBinVectorSum); hold on;
       plot(sleepchangeBinVectorSum, 'r-'); hold off;
       set(gca,'xtick',[])
       set(gca,'xticklabel',[]) 
       legend('Motion data (binned)','Sleep change data (binned)','location','northwest');
       title('MOTION & SLEEP CHANGE - PLOT OF BINS');
    
  end