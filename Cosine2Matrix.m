function cos= Cosine2Matrix(data1,data2,summFlag)

if  nargin<3 ||isempty(summFlag)
    summFlag='nanmean';
end

eval(['fun=@(x) ' summFlag '(x,4);']);
data1=fun(data1);
data2=fun(data2);

data1=reshape(data1,1,size(data1,1)*size(data1,2))';
data2=reshape(data2,1,size(data2,1)*size(data2,2))';

cos=cosine(data1,data2);

VectorNorm1=norm(data1);
VectorNorm2=norm(data2);

end