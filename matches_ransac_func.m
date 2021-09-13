function [ matches_ransac ] = matches_ransac_func( matches_course, fa1, fa2)

% % 利用尺度信息改
% [~,index] = sort(fa1(3,matches_course(1,:)));
% matches_course = matches_course(:,index);
% left = find(round(fa1(3,matches_course(1,:))) == 6,1);
% right = size(matches_course,2);

left = 1;
right = size(matches_course,2);

numMatches = size(matches_course,2);

if numMatches<4
    matches_ransac = [];
    return;
end
    

X1 = fa1(1:2,matches_course(1,:)) ; 
X1(3,:) = 1 ;
X2 = fa2(1:2,matches_course(2,:)) ; 
X2(3,:) = 1 ;

% --------------------------------------------------------------------
%                   RANSAC with homography model
% --------------------------------------------------------------------

clear H score ok ;
for t = 1:1000
    % estimate homograpyh
    subset = vl_colsubset(left:right, 4) ;
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
    ok{t} = (du.*du + dv.*dv) < 6*6 ;
    score(t) = sum(ok{t}) ;
end

[score, best] = max(score) ;
H = H{best} ;
ok = ok{best} ;

[scale,index] = sort(round(fa1(3,matches_course(1,:))));
X1 = X1(:,index);
X2 = X2(:,index);
X2_ = H * X1 ;
du = X2_(1,:)./X2_(3,:) - X2(1,:)./X2(3,:) ;
dv = X2_(2,:)./X2_(3,:) - X2(2,:)./X2(3,:) ;
check_ok = (du.*du + dv.*dv) < 6*6 ;

% divided = find(scale==6,1);
% 1-sum(check_ok(1:divided))/divided
% 1-sum(check_ok(divided:end))/(size(check_ok,2)-divided)

%利用尺度信息改

matches_end_size = size(matches_course(:,ok),2)

matches_ransac = matches_course(:,ok);


