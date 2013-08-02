
local mulFunc = function(self, other) return self.matrMult(other) end
local addFunc = function(self, other) return self.matrAdd(other) end
local unmFunc = function(self) tmp = self.copy(); tmp.scalarMult(-1); return tmp end
local subFunc = function(self, other) return self + (-other) end
local modFunc = function(self, other) return self.compMult(other) end

function Library.LibLinAlg.numMat(_n, _m, toZero)
 
	local base = Library.LibLinAlg.genMat(_n, _m, toZero)
	local self = setmetatable({}, 
		{
			__call = callFunc,
			__eq = eqFunc,
			__concat = concatFunc,
			__mul = mulFunc,
			__add = addFunc,
			__unm = unmFunc,
			__sub = subFunc,
			__mod = modFunc,
			__index = base
		})
		
	getmetatable(getmetatable(self).__index).__index = self
	
	--returns the type of the matrix
	function self.getType() 
		return "numMat" 
	end
	
	--Returns a matrix whose components are the componentwize multiplication of self and other
	function self.compMult(other)
		local n, m = self.getShape()
		local _n, _m = other.getShape()
		
		res = Library.LibLinAlg.numMat(n, m, false)
		
		if not n or not _n or not m or not _m or n == 0 or _n == 0 or m == 0 or _m == 0 then self.Error("Empty matrix in comp matr mult"); return end
		
		if n ~= _n or m ~=_m then self.Error("Dimension mismatch in comp matr mul") return end
		
		for i = 1, n, 1 do
			for j = 1, m, 1 do
				res.at[i][j] = self.at[i][j]*other.at[i][j]
			end
		end
		
		return res
		
	end
	
	--Dumps a clean printout of the matrix to stdout
	function self.dump()
		
		local n, m = self.getShape()
		
		if not self.at then print("[matrix 0x0]"); return end
		
		local s = string.format("[" .. self.getType() .. " %dx%d]", n, m) .. "\n"
		
		for i = 1, n, 1 do
			for j = 1, m, 1 do
				
				if self.at[i][j] then
				
					if self.at[i][j] >= 0 then
						s = s .. string.format(" %3.3f", math.abs(self.at[i][j]))
					else
						s = s .. string.format("-%3.3f", math.abs(self.at[i][j]))
					end
				
				else
					s = s .. "*"
				end
				
				if j ~= m then s = s .. "\t" end
			
			end
			
			s = s .. " |"
			if i ~= n then s = s .. "\n" end
			
		end
		
		print(s)
		
	end
	
	--sets every matrix element to zero
	function self.zeros() self.fill(0) end
	
	--sets every matrix element to one
	function self.ones() self.fill(1) end
	
	--Initializes the identity matrix. 
	--If not quadratic, an nxn identity is created with the remaining elements set to zero.
	function self.eye()
		self.zeros()
		
		local n, m = self.getShape()
		
		local k = math.min(n, m)
		
		for i = 1, k, 1 do
			self.at[i][i] = 1
		end
		
	end
	
	--Adds a given scalar to every element of the matrix
	function self.scalarAdd(C)
	
		local n, m = self.getShape()
	
		for i = 1, n, 1 do
			for j = 1, m, 1 do
				self.at[i][j] = self.at[i][j] + C
			end
		end
	
	end
	
	--Multiplies the matrix with a given scalar
	function self.scalarMult(C)
	
		local n, m = self.getShape()
	
		for i = 1, n, 1 do
			for j = 1, m, 1 do
				self.at[i][j] = self.at[i][j]*C
			end
		end
	
	end
	
	--Performs the matrix product self * other
	function self.matrMult(other)
	
		local n, m = self.getShape()
		local _n, _m = other.getShape()
		
		--Dimension mismatch
		if m ~= _n then self.Error("Dimensions mismatch in matrix multiplication."); return end
		
		local Aij = 0
		local res = Library.LibLinAlg.numMat(n, _m, false)
		
		for i = 1, n, 1 do
			for j= 1, _m, 1 do
			
				Aij = 0
				for k = 1, m, 1 do
					Aij = Aij + self.at[i][k]*other.at[k][j]
				end
				
				res.at[i][j] = Aij
			
			end
		end
		
		return res
	
	end
	
	--Performs the addition self + other
	function self.matrAdd(other)
		
		local n, m = self.getShape()
		local _n, _m = other.getShape()
		
		if _n ~= n or _m ~= m then self.Error("Dimension mismatch in matrix addition."); return end
		
		res = Library.LibLinAlg.numMat(n, m, false)
		
		for i = 1, n, 1 do
			for j = 1, m, 1 do
				res.at[i][j] = self.at[i][j] + other.at[i][j]
			end
		end
		
		return res
		
	end

	return self

end

--Predefinitions of vectors for cleaner code
function Library.LibLinAlg.numColVec(__n, toZero) return Library.LibLinAlg.numMat(__n, 1, toZero) end
function Library.LibLinAlg.numRowVec(__m, toZero) return Library.LibLinAlg.numMat(1, __m, toZero) end
