function [M, z] = normalise(A, dim)
% NORMALISE Make the entries of a (multidimensional) array sum to 1
% [M, c] = normalise(A)
% c is the normalizing constant
%
% [M, c] = normalise(A, dim)
% If dim is specified, we normalise the specified dimension only,
% otherwise we normalise the whole array.

if nargin < 2
  z = sum(A(:));
  s = z + (z==0);
  M = A / s;
elseif dim==1 % normalize each column
  z = sum(A,1);
  s = z + (z==0);
  M = A ./ repmat(s, size(A,1), 1);
else
  z=sum(A,dim);
  s = z + (z==0);
  L=size(A,dim);
  d=length(size(A));
  v=ones(d,1);
  v(dim)=L;
  c=repmat(s,v');
  M=A./c;
end


