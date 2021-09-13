function [ bigransacmatches,resultH ] = matches_ransac_bigscale( bigmatch,fa1,fa2 )
%MATCHES_RANSAC_TWOSCALE RANSAC大尺度配准
%   用大尺度指导小尺度的配准过程，返回bigmatches

numBigMatches = size(bigmatch,2);
if numBigMatches<4
    bigransacmatches = [];
    resultH = [];
    return;
end
    
% --------------------------------------------------------------------
%                              大尺度RANSAC
% --------------------------------------------------------------------
for loop_i = 1:5
    clear H score ok distance X1 X2
    
    X1 = fa1(1:2,bigmatch(1,:)) ; 
    X1(3,:) = 1 ;
    X2 = fa2(1:2,bigmatch(2,:)) ; 
    X2(3,:) = 1 ;
    
    distance = [];
    for t = 1:100
        % estimate homograpyh
        subset = vl_colsubset(1:numBigMatches, 4) ;
        A = [] ;
        for i = subset
            A = cat(1, A, kron(X1(:,i)', vl_hat(X2(:,i)))) ;
        end
        [U,S,V] = svd(A) ;
        H{t} = reshape(V(:,9),3,3) ;

        % score homography
        X2_ = H{t} * X1 ;
        du = X2_(1,:)./X2_(3,:) - X2(1,:)./X2(3,:) ;
        dv = X2_(2,:)./X2_(3,:) - X2(2,:)./X2(3,:) ;
        distance(:,t) = (du.*du + dv.*dv)';
        ok(:,t) = distance(:,t) < (11-loop_i).^2;
        score(t) = sum(ok(:,t)) ;
    end
    
    distance_var = var(distance);
    [~,select_index] = sort(distance_var);
    [~,next_set_index] = max(score(select_index(1:10)));
    bigmatch = bigmatch(:,ok(:,select_index(next_set_index))');
    numBigMatches = size(bigmatch,2);
    if numBigMatches < 4
        break;
    end
end
resultH = H{select_index(next_set_index)};
bigransacmatches = bigmatch;





