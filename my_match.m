function [matches,scores] = my_match(da1, da2, fa1, fa2, threshold, ratio)

matches = [];
scores = [];
for i=1:size(fa1,2)
    temp_scale_value = fa1(3,i);
    temp_da2 = da2;
    temp_da2_del = abs(fa2(3,:) - temp_scale_value) > threshold;
    temp_da2(:,temp_da2_del) = [];
    temp_fa2_back_index = [];
    for j=1:size(fa2,2)
        if temp_da2_del(j) == false
            temp_fa2_back_index(end+1) = j;
        end
    end
    temp_sub = double(da1(:,i))*ones(1,size(temp_da2,2)) - double(temp_da2);
    % 0422 直接用平方距离
    % temp_EucDistance = sqrt(sum(temp_sub.^2))';
    temp_EucDistance = sum(temp_sub.^2)';
    [min_val,min_index] = min(temp_EucDistance);
    temp_EucDistance(min_index) = [];
    sec_min_val = min(temp_EucDistance);
    if(min_val * ratio < sec_min_val)
      matches(1:2,end+1) = [i;temp_fa2_back_index(min_index)];
      scores(end+1) = min_val;
    end
      
%       temp_matches = vl_ubcmatch(da1(:,i),temp_da2);
%       if ~isempty(temp_matches)
%         matches(1:2,end+1) = [i;temp_fa2_back_index(temp_matches(2,1))];
%       end
end

%比例
% function [matches,scores] = my_match(da1, da2, fa1, fa2, ratio)
% 
% matches = [];
% scores = [];
% for i=1:size(fa1,2)
%     temp_scale_value = fa1(3,i);
%     temp_da2 = da2;
%     temp_da2_del = abs(fa2(3,:) - temp_scale_value) > 0.2 * temp_scale_value;
%     temp_da2(:,temp_da2_del) = [];
%     temp_fa2_back_index = [];
%     for j=1:size(fa2,2)
%         if temp_da2_del(j) == false
%             temp_fa2_back_index(end+1) = j;
%         end
%     end
%     temp_sub = double(da1(:,i))*ones(1,size(temp_da2,2)) - double(temp_da2);
%     % 0422 直接用平方距离
%     % temp_EucDistance = sqrt(sum(temp_sub.^2))';
%     temp_EucDistance = sum(temp_sub.^2)';
%     [min_val,min_index] = min(temp_EucDistance);
%     temp_EucDistance(min_index) = [];
%     sec_min_val = min(temp_EucDistance);
%     if(min_val * ratio < sec_min_val)
%       matches(1:2,end+1) = [i;temp_fa2_back_index(min_index)];
%       scores(end+1) = min_val;
%     end
      
%       temp_matches = vl_ubcmatch(da1(:,i),temp_da2);
%       if ~isempty(temp_matches)
%         matches(1:2,end+1) = [i;temp_fa2_back_index(temp_matches(2,1))];
%       end
end