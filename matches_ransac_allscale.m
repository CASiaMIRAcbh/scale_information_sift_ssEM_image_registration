function [ matches ] = matches_ransac_allscale( bigransacmatches,resultH,smallmatch,fa1,fa2 )
%MATCHES_RANSAC_ALLSCALE 全尺度RANSAC
%   在bigransacmatch的指导下进行小尺度点的ransac

X1 = fa1(1:2,smallmatch(1,:)) ; 
X1(3,:) = 1 ;
X2 = fa2(1:2,smallmatch(2,:)) ; 
X2(3,:) = 1 ;

X2_ = resultH * X1;
du = X2_(1,:)./X2_(3,:) - X2(1,:)./X2(3,:) ;
dv = X2_(2,:)./X2_(3,:) - X2(2,:)./X2(3,:) ;
ok = (du.*du + dv.*dv) < 10 * 10;

matches_allscale = smallmatch(:,ok);
numMatches = size(matches_allscale,2);
if numMatches<4
    matches = [];
    return;
end

% 在这里添加一个显示图 由big删掉后的图 临时加上img_1和img_2的参数 之后删掉
% show_compare_sift_points( img_1, img_2, fa1, fa2, matches_allscale )

matches_allscale(:,end+1:end+size(bigransacmatches,2)) = bigransacmatches;

% allscale的图
% show_compare_sift_points( img_1, img_2, fa1, fa2, matches_allscale )


X1 = fa1(1:2,matches_allscale(1,:)) ; 
X1(3,:) = 1 ;
X2 = fa2(1:2,matches_allscale(2,:)) ; 
X2(3,:) = 1 ;

% --------------------------------------------------------------------
%                              全尺度RANSAC
% --------------------------------------------------------------------
clear H score ok ;
for t = 1:1000
    % estimate homograpyh
    subset = vl_colsubset(1:numMatches, 4) ;
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
matches = matches_allscale(:,ok);

% pick = 1:numMatches;
% for loop_i = first_threshold:-1:3
%     loop_i
%     clear H score ok distance X1 X2 inbox
%     
%     X1 = fa1(1:2,matches_smallscale(1,:)) ; 
%     X1(3,:) = 1 ;
%     X2 = fa2(1:2,matches_smallscale(2,:)) ; 
%     X2(3,:) = 1 ;
%     
%     distance = [];
%     teacher_score = [];
%     pre_del = false(1,numMatches);
%     for t = 1:100
%         t
%         % estimate homograpyh
%         subset = vl_colsubset(pick, 4) ;
%         A = [] ;
%         for i = subset
%             A = cat(1, A, kron(X1(:,i)', vl_hat(X2(:,i)))) ;
%         end
%         [U,S,V] = svd(A) ;
%         H{t} = reshape(V(:,9),3,3) ;
% 
%         % score homography
%         X2_ = H{t} * X1 ;
%         du = X2_(1,:)./X2_(3,:) - X2(1,:)./X2(3,:) ;
%         dv = X2_(2,:)./X2_(3,:) - X2(2,:)./X2(3,:) ;
%         distance(:,t) = (du.*du + dv.*dv)';
%         inbox(:,t) = distance(:,t) < 1;
%         score(t) = sum(distance(:,t) < loop_i.^2);
%         inbox_score(t) = sum(inbox(:,t)) - 4 ;
%         
%         % 大尺度重新参与监督
%         teacher_X2_ = H{t} * teacher_X1;
%         teacher_du = teacher_X2_(1,:)./teacher_X2_(3,:) - teacher_X2(1,:)./teacher_X2(3,:) ;
%         teacher_dv = teacher_X2_(2,:)./teacher_X2_(3,:) - teacher_X2(2,:)./teacher_X2(3,:) ;
%         teacher_score(t) = sum((teacher_du.*teacher_du + teacher_dv.*teacher_dv) < first_threshold * first_threshold);
%         
%         %预判一些删除的点 过删除
%         if inbox_score(t) < 5
%             pre_del(subset) = true;
%         end
%         if teacher_score(t) < 5
%             pre_del(subset) = true;
%         end
%     end
%     matches_smallscale(:,pre_del) = [];
%     
%     [~,select_index] = sort(teacher_score,'descend');
%     [~,next_set_index] = max(score(select_index(1:10)));
%     
%     pick = distance(:,next_set_index)';
%     pick = pick < loop_i.^2;
%     pick(pre_del) = [];
%     pick_result = [];
%     for temp_pick = 1:size(pick,2)
%         if pick(temp_pick) == true
%             pick_result(end+1) = temp_pick;
%         end
%     end
%     pick = pick_result;
% 
% end
% matches = matches_smallscale;
