function getDiceResult(nCount, nDie)
	local nResult = 0;
	
	for i = 1, nCount
	do
		nResult = nResult + math.random(nDie);
	end
	
	return nResult;
end;
