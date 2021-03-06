function a=GJE2(H,B)
a=[H,B];
[m,n]=size(a);

col=1;
RANK=0;
for row= 1: m % rank = n-col; may be smaller
    while( col<=n && a(row, col)~=1)        
        %This is PIVOTING
        for idx=row+1: m
            if a(idx, col)==1
                t=a(row, :);
                a(row, :)= a(idx, :);
                a(idx, :)= t;
            end
        end
        
        if(a(row, col)==0)
            col= col+1; 
        end
       
    end
    
    if col>n 
        
        break;
    end
    RANK=RANK+1;
    for idx= row+1: m
        if a(idx, col)==1
            a(idx, :)=mod(a(idx, :) + a(row, :)*a(idx, col), 2); 
        end
    end   
    
    col=col+1;
end
% BACK SUBSTITUTION
col=col-1;
for ibx= RANK: -1: 2
    
    while (a(ibx,col)==0)
       col=col-1; 
    end
    for iby = ibx-1: -1: 1
        a(iby,:)=mod(a(iby, :)+a(ibx,:)*a(iby,col), 2);
    end
end
    
end