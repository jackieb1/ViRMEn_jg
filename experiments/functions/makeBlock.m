function seq = makeBlock(n_each)
% Build base list with n_each of each type (1,2,3) in random order
base = [repmat(1,1,n_each), repmat(2,1,n_each), repmat(3,1,n_each)];
base = base(randperm(numel(base)));

% Insert a control (3) immediately after each forward (1)
seq = [];
for i = 1:numel(base)
    seq(end+1) = base(i); %#ok<AGROW>
    if base(i) == 1
        seq(end+1) = 3;   %#ok<AGROW>  % extra control after each forward
    end
end
end