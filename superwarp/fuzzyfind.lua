-- thanks to Lili for doing this research.
 
-- https://www.lua.org/wshop12/Snyder1.pdf
local function LCS(A, i1, i2, B, j1, j2, L)
    local p
    if (i2 < i1) or (j2 < j1) then
        p = 0
    else
        p = L[i2][j2]
        if p < 0 then
            if A[i2] == B[j2] then
                p = LCS(A, i1, i2-1, B, j1, j2-1, L) + 1
            else
                local a1 = LCS(A, i1, i2, B, j1, j2-1, L)
                local b1 = LCS(A, i1, i2-1, B, j1, j2, L)
                p = math.max(a1, b1)
            end
            L[i2][j2] = p
        end
    end
    return p
end
 
local function path_extract1(L, A, i, B, j)
    if (i == 0) or (j == 0) then
        return ""
    elseif A[i] == B[j] then
        return path_extract1(L, A, i-1, B, j-1) .. A[i]
    else
        local x1, x2
        if j == 1 then
            x1 = -1
        else
            x1 = L[i][j-1]
        end
        if i == 1 then
            x2 = -1
        else
            x2 = L[i-1][j]
        end
        if x1 > x2 then
            return path_extract1(L, A, i, B, j-1)
        else
            return path_extract1(L, A, i-1, B, j)
        end
    end
end

-- https://en.wikipedia.org/wiki/Levenshtein_distance
function LEV(a,b)
  local M = {}
  local row,col = #a+1,#b+1
  for i = 1,row do 
    M[i] = {}
    for j = 1,col do 
        M[i][j] = 0 
    end
  end
  for i = 1,row do M[i][1] = i-1 end
  for j = 1,col do M[1][j] = j-1 end
  local cost = 0
  for i = 2,row do
    for j = 2,col do
      if (a:sub(i-1,i-1) == b:sub(j-1,j-1)) then cost = 0 --not too happy about :sub
      --if (A[i-1][i-1] == B[j-1][j-1]) then cost = 0
      else cost = 1
      end
    M[i][j] = math.min(math.min(M[i-1][j]+1,M[i][j-1]+1),M[i-1][j-1]+cost)
    end
  end
  return M[row][col]
end

-- fmatch(string needle, table haystack)
-- iterates haystack 
-- if perfect match is found, return it immediately and stop
-- otherwise look for longest LCS (perfect substrings score #needle+1)
-- when two are found with same LCS, calculates Levenshtein distance for both
-- and chooses lowest one. If they're still the same it chooses the shortest string.
-- If they're the same length it just keeps first match.
function fmatch(needle,haystack)
    local A = {}
    local needle = needle:gsub('[^%w%s]',''):lower()
    for i=1,string.len(needle) do
        A[i] = string.sub(needle, i, i)
    end

    local result
    local resultvalue = -1
    for _,v in ipairs(haystack) do
        local vl = v:gsub('[^%w%s]',''):lower()
        if vl == needle then
            return v, 10000
        end    
        local B = {}
        for j=1,string.len(vl) do
            B[j] = string.sub(vl, j, j)
        end
        local L = {}
        for i=1,#A do
            L[i] = {}
            for j=1,#B do
                L[i][j] = -1
            end
        end

        local m = -1
        if vl:find(needle) then
            m = #needle+1
        else
            m = LCS(A,1,#A,B,1,#B,L)
        end
        if m > resultvalue then 
            result = v
            resultvalue = m
        elseif m == resultvalue then
            local d1 = LEV(needle,string.lower(result))
            local d2 = LEV(needle,vl)
            
            local med = d1
            if d2 == d1 and #vl < #result or d2 < d1 then
                result = v
                resultvalue = m
                med = d2
            end     
        end
    end
    return result, resultvalue
end