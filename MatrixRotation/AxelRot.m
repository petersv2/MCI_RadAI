function varargout=AxelRot(varargin)

if nargin>3
    
   XYZold=varargin{1};
   varargin(1)=[];
    
   [R,t]=AxelRot(varargin{:});
    
   XYZnew=bsxfun(@plus,R*XYZold,t);
   
   varargout={XYZnew, R,t};
   
   return; 
   
end

    [deg,u]=deal(varargin{1:2});
    
    if nargin>2, x0=varargin{3}; end

    R3x3 = nargin>2 && isequal(x0,'R');

    if nargin<3 || R3x3 || isempty(x0), 
        x0=[0;0;0]; 
    end

    x0=x0(:); u=u(:)/norm(u);

    AxisShift=x0-(x0.'*u).*u;




    Mshift=mkaff(eye(3),-AxisShift);

    Mroto=mkaff(R3d(deg,u));

    M=inv(Mshift)*Mroto*Mshift;

    varargout(1:2)={M,[]};
    
    if R3x3 || nargout>1 
      varargout{1}=M(1:3,1:3);
    end
    
    if nargout>1,
      varargout{2}=M(1:3,4);  
    end

    
    
function R=R3d(deg,u)
%R3D - 3D Rotation matrix counter-clockwise about an axis.
%
%R=R3d(deg,axis)
%
% deg: The counter-clockwise rotation about the axis in degrees.
% axis: A 3-vector specifying the axis direction. Must be non-zero

    R=eye(3);
    u=u(:)/norm(u);
    x=deg; %abbreviation

    for ii=1:3

        v=R(:,ii);

        R(:,ii)=v*cosd(x) + cross(u,v)*sind(x) + (u.'*v)*(1-cosd(x))*u;
          %Rodrigues' formula

    end



function M=mkaff(varargin)


    if nargin==1

       switch numel(varargin{1}) 

           case {4,9} %Only rotation provided, 2D or 3D

             R=varargin{1}; 
             nn=size(R,1);
             t=zeros(nn,1);

           case {2,3}

             t=varargin{1};
             nn=length(t);
             R=eye(nn); 

       end
    else

        [R,t]=deal(varargin{1:2});
        nn=size(R,1);
    end

    t=t(:); 

    M=eye(nn+1);

    M(1:end-1,1:end-1)=R;
    M(1:end-1,end)=t(:); 

