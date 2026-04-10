function n = ndim(x)
% Report the number of non singleton dimensions of a matlab array.

%@info:
%! @deftypefn {Function File} {@var{n} =} ndim (@var{x})
%! @anchor{ndim}    
%! This function reports the number of non singleton dimensions of a matlab array.
%!
%! @strong{Inputs}
%! @table @var
%! @item x
%! Matlab array.
%! @end table
%!
%! @strong{Outputs}
%! @table @var
%! @item n
%! Integer scalar. The number of non singleton dimensions of a matlab array.
%! @end table
%!    
%! @strong{This function is called by:} 
%! @ref{demean}, @ref{nandemean}.
%!    
%! @strong{This function calls:}
%! none.
%!    
%! @end deftypefn
%@eod:

% Copyright (C) 2011 Dynare Team
% stephane DOT adjemian AT ens DOT fr
%    
% This file is part of Dynare.
%
% Dynare is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% Dynare is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with Dynare.  If not, see <http://www.gnu.org/licenses/>.

n = sum(size(x)>1);