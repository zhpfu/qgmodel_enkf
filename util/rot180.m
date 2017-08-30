function rfield = rot180(field)

% rfield = ROT180(field)  
%     Rotates field by 180 degrees in horizontal
%     plane (field can be either 2 or 3 dimensional).

switch ndims(field)
  case 2, rfield=rot90(rot90(field));
  case 3
    for n=1:size(field,3)
      rfield(:,:,n) = rot90(rot90(field(:,:,n)));
    end
end