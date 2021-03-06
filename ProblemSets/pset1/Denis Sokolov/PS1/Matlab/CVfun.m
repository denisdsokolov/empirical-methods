function MSE = CVfun(data,bw,k,num)
% bw - bandwith
% k - # of data bids for CV
% num - number of the bid for test data

l = length(data);
ind1Train = ceil((l/k)*(num-1))+1;
ind2Train = floor((l/k)*num);
train = data(ind1Train:ind2Train); %train data
test = data(setdiff(1:l,ind1Train:ind2Train)); %test data

train = sort(train);
pdEp = fitdist(train,'kernel','Kernel','epanechnikov','BandWidth',bw);
pEp = pdf(pdEp,train); %estimated pdf on train data
%--------------
% we need indexes i s.t. train(i) = train(i-1) (we cant have same x points for griddedInterpolant(x,y))
t1 = train(2:end) - train(1:end-1);
indx = find(t1==0)+1; % needed indexes
indx1 = setdiff(1:length(train),indx);
train1 = train(indx1);
pEp1 = pEp(indx1);
%--------------
F = griddedInterpolant(train1,pEp1);
fun = @(t) F(t); % estimated pdf on train data as function

b = 5; % # of bids for MSE

[N,edges] = histcounts(test,b);
edges = [min(train) edges(2:end-1) max(train)]; % edges for integration for MSE
testN = sum(N); % # of test obs
N = N/testN; % N as fractions

MSE = 0;
for i = 1:b
    q = integral(fun, edges(i), edges(i+1));
    MSE = MSE + (q - N(i))^2;
end

end