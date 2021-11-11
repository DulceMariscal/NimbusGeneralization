function VectorNorm1=getNorm(data1)

if  nargin<3 ||isempty(summFlag)
    summFlag='nanmean';
end

eval(['fun=@(x) ' summFlag '(x,4);']);
data1=fun(data1);


data1=reshape(data1,1,size(data1,1)*size(data1,2))';

VectorNorm1=norm(data1);

end