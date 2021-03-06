function [ERRORARR,WORDSARR]=TrySix()
k=              128;
r=              4;
m=              8;
n=              2^m;
col=            k;
nosWords=       1;
% snr=            03;
%%
% define generator matrix 0
G1=             main1_v2(k,r,m);
G2=             main2_v2(k,r,m);
G3=             main3(k,r,m);

% get encoded word
% [EncWordArr1,EncWordArr2,EncWordArr3,~]=wordGenerator_v4(nosWords,col,G1,G2,G3);
% make a noisy word
%%
WORDSARR=      [];
ERRORARR=      [];
for snr=2.5:0.5:3
    TotalWords=     [0 0 0];
    %     TotalError1=    [0 0 0];
    TotalError2=    [0 0 0];
    % check for 100 words;
    
    [EncWordArr,~,~,~]=wordGenerator_v4(nosWords,col,G1,G2,G3);
    outer=1;
    G=G1;
    h=comm.AWGNChannel('EbNo',snr);
    RecWordArr=      step(h,EncWordArr*2-1);
    for idy=1:nosWords
        EncWord=        EncWordArr(idy,:);
        RecWord=        RecWordArr(idy,:);
        %% Confidence values and detected word via threshold detection:
        % HARD DECISION
        HardDecision=   RecWord>0;
        Confidence=     abs(RecWord);
        y=              1:n;
        
        % SOFT DECISION - ORDER 0
        ARR=            [Confidence;HardDecision;EncWord;RecWord;G;y].';
        ARR=            sortrows(ARR,-1);
        ARR=            ARR.';
        %     S_Confidence=   ARR(1,:);
        S_HardDecision= ARR(2,:);
        S_EncWord=      ARR(3,:);
        %     S_RecWord=      ARR(4,:);
        S_G=            ARR(5:(end-1),:);
        y1=             ARR(end,:); % ORIGNAL PERMUTATION
        
        % Selection of K INDEPENDENT columns of MAXIMUM confidence
        CurrentRowNumber=1;
        GIndep=          [];
        GDep=            [];
        y2=             1:n;
        S_G=            [S_G;y2;S_EncWord;S_HardDecision;y1];
        S_Gcopy=S_G;
        S_G=gf(S_G,1);
        while CurrentRowNumber<=k
            CurrentColumn=  S_G(:,CurrentRowNumber);
            if(CurrentColumn(CurrentRowNumber)~=1)
                if(CurrentColumn(CurrentRowNumber:k)==0)% not independent SO SEND IT TO THE END
                    S_G=[S_G,CurrentColumn];
                    S_G(:,CurrentRowNumber)=[];
                    continue;
                else
                    loc=CurrentRowNumber+find(CurrentColumn(CurrentRowNumber+1:k),1);
                    %                             Swapping row LOC and row CURRENTROWNUMBER
                    tempRow=S_G(CurrentRowNumber,:);
                    S_G(CurrentRowNumber,:)=S_G(loc,:);
                    S_G(loc,:)=tempRow;
                end
            end
            
            
            %     forward elemination
            for idx=(CurrentRowNumber+1):k
                S_G(idx,:)=mod(S_G(idx,:)+S_G(CurrentRowNumber,:).*S_G(idx,CurrentRowNumber),2);
            end
            
            %     Back Elemination
            for idx=1:(CurrentRowNumber-1)
                S_G(idx,:)=mod(S_G(idx,:)+S_G(CurrentRowNumber,:).*S_G(idx,CurrentRowNumber),2);
            end
            CurrentRowNumber=CurrentRowNumber+1;
        end
        S_G2=           S_G(1:k,:);
        %     y2=             S_G(k+1,:);
        S_EncWord=      S_G(k+2,:);
        S_HardDecision= S_G(k+3,:);
        %     y1=             S_G(k+4,:);
        
        ConfidenceBits=S_HardDecision(1:k);
        Re_EncWord=mod(ConfidenceBits*S_G2,2);
        
        ErrorMat=sum(mod(Re_EncWord+S_EncWord,2));
        TotalError2(outer)=TotalError2(outer)+(ErrorMat>0);
        
        
    end
    
    
    WORDSARR=[WORDSARR;snr,TotalWords];
    ERRORARR=[ERRORARR;snr,TotalError2];
end
end
