-- Returns false if value is falsey (`nil` or `false`), returns true if value is truthy (everything else)
function toboolean(v)
    return v ~= nil and v ~= false
end

-- Returns true if one value is falsey and the other is truthy, returns false otherwise
function xor(a, b)
    return toboolean(a) ~= toboolean(b)
end