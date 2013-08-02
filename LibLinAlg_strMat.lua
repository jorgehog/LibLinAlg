
local addFunc = function(self, other) return self.strAdd(other) end

function Library.LibLinAlg.strMat(__n, __m, blank)

	local base = Library.LibLinAlg.genMat(__n, __m, false)
	local self = setmetatable({}, 
		{
			__call = callFunc,
			__eq = eqFunc,
			__concat = concatFunc,
			__add = addFunc,
			__index = base
		})
	
	getmetatable(getmetatable(self).__index).__index = self
	
	--Returns the matrix type
	function self.getType()
		return "strMat"
	end
	
	--Concatinates the strings for each element.
	function self.strAdd(other)
		
		local n, m = self.getShape()
		local _n, _m = other.getShape()
		
		if _n ~= n or _m ~= m then self.Error("Dimension mismatch in matrix addition."); return end
		
		res = Library.LibLinAlg.strMat(n, m, false)
		
		for i = 1, n, 1 do
			for j = 1, m, 1 do
				res.at[i][j] = self.at[i][j] .. other.at[i][j]
			end
		end
		
		return res
		
	end
	
	--Sets every element to an empty string
	function self.blank() self.fill("") end
	
	--expr is a string which will fill every element, with $i and $j being replaced by the matrix indices.
	--if offsets are given, $i = i + xOffset, $j = j + yOffset
	function self.quickFill(expr, xOffset, yOffset)
		
		local n, m = self.getShape()
		
		if not n or not m or n == 0 or m == 0 then self.Error("Can't quickfill an empty matrix."); return end
		
		if not xOffset then xOffset = 0 end
		if not yOffset then yOffset = 0 end
		
		for i = 1, n, 1 do
			for j = 1, m, 1 do
				self.at[i][j] = string.gsub(string.gsub(expr, "$i", i + xOffset), "$j", j + yOffset)
			end
		end
		
	end
	
	
	if blank then self.blank() end
	
	return self
	
end

function Library.LibLinAlg.strVec(n, blank) return Library.LibLinAlg.strMat(n, 1, blank) end
