function vr = createBlockStructure(vr,initBlock)

nBlocks = length(vr.sessionSwitchpoints)+1;
blockIDs = mod(initBlock:initBlock+nBlocks-1,2) + 1;
blockMazes = [1 2;3 4];
for nBlock = 1:nBlocks
    vr.contingentBlocks(nBlock,:) = blockMazes(blockIDs(nBlock),:);
end