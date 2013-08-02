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
--concatFunc = function(self, other) return self.concat(other) end --Lua users really didn't like this!
strFunc = function(self) return self.dumpString() end


print("main matrix library loaded")

--main matrix class. May contain any object.
function Library.LibLinAlg.Matrix(_n, _m, toZero)

	

	local self = setmetatable({at = nil, isMatrix=true}, {
			__call = callFunc,
			__eq = eqFunc,
			__tostring = strFunc,
			--__concat = concatFunc
		})
	
	local n, m = nil, nil
	


	
	--Error handler
	function self.Error(message)
		assert(false, "\nERROR: " .. message .. "\n")
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
	function self.joinColumns(other)
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
	
	--Appends the columns of other to the end of self
	function self.joinRows(other)
		local _n, _m = other.getShape()
		
		if _n == 0 or n == 0 then
			self.Error("Concatenation attempted with empty matrices.")
		end
		
		if _m ~= m then
			self.Error("Mismatch in the number of columns when attempting to join rows.")
		end
		
		res = self.copy()
		res.setSize(n + _n, m, false, true)
		
		for i = n + 1, n + _n, 1 do
			for j = 1, m, 1 do
				res.at[i][j] = other(i - n, j)
			end
		end
		
		return res
	
	end
	
	
	--Private function. Sets the size of the matrix. 
	--If keepMem is true, previous memory is not overridden.
	local function makeMatrix(toZero, keepMem)
		
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
		
		if not keepMem then return tmp end
		
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
			if not (type(_n) == "number" and type(_m) == "number") then self.Error("Given size of matrix must be given as two integers") end

			if __n == 0 or __m == 0 then __n = 0; __m = 0 end
			
			if __n >= 0 and __m >= 0 then
				n = __n
				m = __m
			else
				self.Error("Attempt to set negative size matrix")
			
			end
		else
			n = 0
			m = 0
		end
		
		self.at = makeMatrix(toZero, keepMem)
	
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
		
		if n == 0 then return copy end 
	
		for i = 1, n, 1 do
			for j = 1, m, 1 do
				copy.at[i][j] = self.at[i][j]
			end
		end
		
		return copy
	
	end
	
	--Returns an object with the correct type.
	function self._getNewMat()
	
		local _type = nil
		if self.getType then _type = self.getType() else _type = "Matrix" end

		return loadstring("return function() return Library.LibLinAlg." .. _type .. " end")()()

	end
	
	--Dumps a clean printout of the matrix to stdout
	function self.dumpString()

		local _type = "Matrix"
		if self.getType then _type = self.getType() end


		if #self.at == 0 then 
			return string.format("[%s 0x0]", _type) 
		end
		
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
		
		return s
		
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
	
	--Returns all the elements in a single table
	function self.getElementsAsTable(columnWise)
	
		local first, second = nil, nil
		local getItem = nil
	
		if columnWise then
			first = m
			second = n
			getItem = function (i, j) return self(j, i) end
		else
			first = n
			second = m
			getItem = function (i, j) return self(i, j) end
		end
		
		elementTable = {}
		local k = 1
		
		for i = 1, first, 1 do
			for j = 1, second, 1 do
				elementTable[k] = getItem(i, j)
				k = k + 1
			end
		end
		
		return elementTable
	
	end
	
	--Removes row number i from the matrix and returns it
	function self.popRow(i)
		
		if not i then i = n end
		
		if i <= 0 or i > n then
			self.Error("Unable to pop selected Row. Out of bounds.")
		end
		
		local pop = self.at[i]
		
		table.remove(self.at, i)
		n = n - 1
		
		return pop
	
	end
	
	--Removes column number i from the matrix and returns it
	function self.popColumn(i)
		
		if not i then i = m end
		
		if i <= 0 or i > m then
			self.Error("Unable to pop selected Column. Out of bounds.")
		end
		
		local pop = {}
		for k = 1, n, 1 do
			pop[k] = self(k, i)
			table.remove(self.at[k], i)
		end
		m = m - 1
		
		return pop
		
	end
	
	
	--Inserts a matrix' rows into another matrix at index i
	function self.insertRows(other, i)
	
		if not i then i = n + 1 end
	
		--Automatically converts a given table to a matrix
		if not other.isMatrix and type(other) == "table" then other = self._getNewMat()(other) end
		
		local _n, _m = other.getShape()
		
		--If the appended matrix is empty we do nothing
		if _n == 0 then return end
		
		--If the current matrix is empty, we make a copy of the given matrix
		if n == 0 then 
			self.at = other.at
			self.setSize(_n, _m, false, true)
			return 
		end
		
		if m ~= _m then 
			self.Error("Mismatch in insertRows. The number of columns must match.")
		end
		
	
		if i <= 0 or i > n + 1 then
			self.Error("Unable to insert row. Out of bounds")
		end
		
		for k = i, i + _n - 1, 1 do
			table.insert(self.at, k, other.at[k - i + 1])
		end
		
		n = n + _n
		
	end
	
	
	--Inserts a matrix' columns into another matrix at index i
	function self.insertColumns(other, i)
	
		if not i then i = m + 1 end
	
		--Automatically converts a given table to a matrix
		if not other.isMatrix and type(other) == "table" then other = self._getNewMat()(other) end
		
		local _n, _m = other.getShape()
		
		--If the appended matrix is empty we do nothing
		if _n == 0 then return end
		
		--If the current matrix is empty, we make a copy of the given matrix
		if n == 0 then 
			self.at = other.at
			self.setSize(_n, _m, false, true)
			return 
		end
		
		if n ~= _n then 
			self.Error("Mismatch in insertColumns. The number of rows must match.")
		end
		
	
		if i <= 0 or i > m + 1 then
			self.Error("Unable to insert column. Out of bounds")
		end
		

		for j = 1, n, 1 do
			for k = i, i + _m - 1, 1 do --k = index of column
				table.insert(self.at[j], k, other.at[j][k - i + 1])
			end
		end
		
		m = m + _m
		
	end
	
	--Swaps rows i and j in the matrix
	function self.swapRows(i, j)
	
		if not i or not j then
			self.Error("Indices must be supplied to the swap function")
		end
	
		if i < 1 or i > n or j < 1 or j > n then
			self.Error("Index out of bounds in swap rows method")
		end
		
		if i == j then return end
		
		local tmp = self.at[i]
		
		self.at[i] = self.at[j]
		self.at[j] = tmp
	
	end
	
	--Swaps columns i and j in the matrix
	function self.swapColumns(i, j)
	
		if not i or not j then
			self.Error("Indices must be supplied to the swap function")
		end
	
		if i < 1 or i > m or j < 1 or j > m then
			self.Error("Index out of bounds in swap rows method")
		end
		
		if i == j then return end
		
		local tmp = nil
		for k = 1, n, 1 do
			tmp = self.at[i][k]
			self.at[k][i] = self.at[k][j]
			self.at[k][j] = tmp
		end
	
	end
	
	
	--Splits the matrix at index column i and returns the products
	function self.splitMatrixRows(i)
		if not i then 
			self.Error("Index to split at must be given to function.")
		end
		
		if i < 1 or i > n then
			self.Error("Index out of bounds.")
		end
	
		local upperMatrix = self.copy()
		local newData = {}
		local row = nil
		for k = i, n, 1 do
			row = upperMatrix.popRow(i)
			table.insert(newData, row)
		end
		
		return upperMatrix, self._getNewMat()(newData)
	
	
	end
	
	
	--Splits the matrix at index row i and returns the products
	function self.splitMatrixColumns(i)
		if not i then 
			self.Error("Index to split at must be given to function.")
		end
		
		if i < 1 or i > m then
			self.Error("Index out of bounds.")
		end
	
		local leftMatrix = self.copy()
		local newData = {}
		local row = nil
		for k = i, m, 1 do
			row = leftMatrix.popColumn(i)
			table.insert(newData, row)
		end
		
		return leftMatrix, self._getNewMat()(newData).transpose()
	
	end
	
	
	
	function self.setMatrixFromTable(t)
	
		print("creating matrix from table")
		
		
		n = #t
		local vector = false
		
		if n ~= 0 then
			if type(_n[1]) == "table" then
				m = #t[1]
			else
				m = n
				n = 1
				vector = true
			end
		else
			m = 0
		end
		
		if not vector then
			for i = 2, n, 1 do
		
				if type(t) ~= "table" then 
					self.Error("Creating matrix from nested table failed due to non-table elements in top layer table.")
					return
				end
				
				if #t[i] ~= m then
					self.Error("Creating matrix from nested table failed due to uneven row sizes.")
					return
				end
	
			end
			
			self.at = {}
		
			for i = 1, n, 1 do
				self.at[i] = {}
				for j = 1, m, 1 do
					self.at[i][j] = t[i][j]
				end
			end

		else
		
			--Make a shallow copy of the input to not run into assignment issues with the pointers
			self.at = {{}}
			for i = 1, m, 1 do
				self.at[1][i] = t[i]
			end
			
		end
	
		
	end
	
	--Initialize the matrix
	if type(_n) == "table" and not _m and not toZero then
		if not _n.isMatrix then 
			self.setMatrixFromTable(_n)
		else
			self.setMatrixFromTable(_n.at)
		end
	else
		self.setSize(_n, _m, toZero, false)
	end

	return self
	
end

--Predefinitions of vectors for cleaner code.
function Library.LibLinAlg.genVec(__n, toZero) return Library.LibLinAlg.Matrix(__n, 1, toZero) end
