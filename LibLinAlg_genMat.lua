--[[
    Copyright (C) 2013  Orlanda

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
--]]


eqFunc = function(self, other) return self.checkEq(other) end
callFunc = function (self, i, j) 
				if  not j then return self.at[1][i] else return self.at[i][j] end 
			end
concatFunc = function(self, other) return self.concat(other) end

--main matrix class. May contain any object.
function Library.LibLinAlg.genMat(_n, _m, toZero)

	local self = setmetatable({at = nil}, {
			__call = callFunc,
			__eq = eqFunc,
			__concat = concatFunc
		})
	
	local n, m = nil, nil	
	
	--Error handler
	function self.Error(message)
		print("\nERROR: " .. message .. "\n")
	end
	
	
	--returns the shape of the matrix (n x m)
	function self.getShape()
		return n, m
	end
	
	--Checks whether all components of self and other is equal or not
	function self.checkEq(other)

		if not n or n == 0 or not m or m == 0 then return true end
		
		for i = 1, n, 1 do
			for j = 1, m, 1 do
				if self.at[i][j] ~= other.at[i][j] then return false end
			end
		end
		
		return true
		
	end
	
	--Appends the columns of other to the end of self
	function self.concat(other)
		local _n, _m = other.getShape()
		
		if not _n or not n or not m or not _m then self.Error("Error: Concatinating empty matrix."); return end
		if _n == 0 or n == 0 or m == 0 or _m == 0 then self.Error("Error: Concatinating empty matrix."); return end
		if _n ~= n then self.Error("Matrices must have the same number of rows for appending.") return end
		
		res = self.copy()
		res.setSize(n, m + _m, false, true)
		
		for i = 1, n, 1 do
			for j = m + 1, _m + m, 1 do
				res.at[i][j] = other.at[i][j - m]
			end
		end
		
		return res
		
	end
	
	--Private function. Sets the size of the matrix. 
	--If keepMem is true, previous memory is not overridden.
	local function makeMatrix(toZero, keepMem)

		if n == 0 or not n or m == 0 or not m then self.freeMatrix(); return end
		
		if keepMem == nil then keepMem = true end
		if toZero == nil then toZero = true end
		
		
		local tmp = {}
		
		local setVal = nil
		if toZero then setVal = 0 end
			
		
		for i = 1, n, 1 do
			tmp[i] = {}
			
			for j = 1, m, 1 do
				tmp[i][j] = setVal
			
			end
		end
		
		if not keepMem or not self.at then return tmp end
		
		for i = 1, n, 1 do
			tmp[i] = {}
			
			for j = 1, m, 1 do
				tmp[i][j] = setVal
			
			end
		end
		
		local I = math.min(#self.at, n)
		local J = math.min(#self.at[1], m)
		
		for i = 1, I, 1 do
			for j = 1, J, 1 do
				tmp[i][j] = self.at[i][j]
			end
		end
			
		return tmp
		
	end
	
	--Sets the size of the matrix. If matrix elements are already initialized,
	--an option to keep the memory from the old matrix is available (true by default)
	--If toZero is true, uninitialized elements will be set to zero instead of nil
	function self.setSize(__n, __m, toZero, keepMem)
		
		n = nil
		m = nil
		
		if __n and __m then
			if __n > 0 and __m > 0 then
			
				n = __n
				m = __m
			
			end
		end
		
		self.at = makeMatrix(toZero, keepMem)
	
	end
	
	--resets the matrix
	function self.freeMatrix()
		self.at = nil
		m = nil
		n = nil
	end
	
	--Sets every matrix element to a given value
	function self.fill(value)
	
		for i = 1, n, 1 do
			for j = 1, m, 1 do
				self.at[i][j] = value
			end
		end
	
	end
	
	
	--Performs a deep copy of the object
	function self.copy()
	
		local n, m = self.getShape()
	
		local copy = self._getNewMat()(n, m)
		
		if not n or n == 0 or not m or m == 0 then return copy end 
	
		for i = 1, n, 1 do
			for j = 1, m, 1 do
				copy.at[i][j] = self.at[i][j]
			end
		end
		
		return copy
	
	end
	
	--Returns an object with the correct type.
	function self._getNewMat()
		
		if self.getType then _type = self.getType() else _type = "genMat" end
		
		return loadstring("return function() return Library.LibLinAlg." .. _type .. " end")()()

	end
	
	--Dumps a clean printout of the matrix to stdout
	function self.dump()
		
		if not self.at then print("[matrix 0x0]"); return end
		
		local _type = "genMat"
		if self.getType then _type = self.getType() end
		
		local s = string.format("[" .. _type .. " %dx%d]", n, m) .. "\n"
		
		for i = 1, n, 1 do
			for j = 1, m, 1 do
				
				if self.at[i][j] then
					s = s .. self.at[i][j]
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
	
	--Transposes the matrix, such that a(i,j) -> a(j, i)
	function self.transpose()
		
		local trans = self._getNewMat()(m, n)
		
		if not n or not m or n == 0 or m == 0 then return trans end
		
		for i = 1, n, 1 do
			for j = 1, m, 1 do
				trans.at[j][i] = self.at[i][j]
			end
		end
		
		return trans

	end
	
	--Applies a function f with arguments ... to all functions.
	--If sendIndices is true, i and j will be supplied as the two first arguments to f
	function self.foreach(sendIndices, f, ...) 
	
		local n, m = self.getShape()
		
		if not n or not m or n == 0 or m == 0 then self.Error("Can't apply functions to an empty matrix."); return end
		
		local element = nil
	
		for i = 1, n, 1 do
			for j = 1, m, 1 do
			
				if sendIndices then
					element = f(i, j, ...)
				else
					element = f(...)
				end
			
				self.at[i][j] = element 
			
			end
		end
		
	end

	
	self.setSize(_n, _m, toZero, false)
	
	return self
	
end

--Predefinitions of vectors for cleaner code.
function Library.LibLinAlg.genVec(__n, toZero) return Library.LibLinAlg.genMat(__n, 1, toZero) end
