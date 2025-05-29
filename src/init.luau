--// tutility

local tutility = {}

--// Public

function tutility.shallow_iterate(tbl: { [any]: any }, callback: (value: any, index: any) -> ())
	if type(tbl) ~= "table" or type(callback) ~= "function" then
		return
	end

	for index: any, value: any in tbl do
		pcall(callback, value, index)
	end
end

function tutility.deep_iterate(
	tbl: { [any]: any },
	callback: (value: any, index: any, parent: { [any]: any }) -> (),
	cache: { [{ [any]: any }]: boolean }?
)
	if type(tbl) ~= "table" or type(callback) ~= "function" then
		return
	end

	cache = cache or {}

	if (cache :: { [{ [any]: any }]: boolean })[tbl] then
		return
	end

	(cache :: { [{ [any]: any }]: boolean })[tbl] = true

	for index: any, value: any in tbl do
		pcall(callback, value, index, tbl)

		if type(value) == "table" then
			tutility.deep_iterate(value, callback, cache)
		end
	end
end

function tutility.shallow_copy<T>(tbl: T): T
	return (table.clone(tbl :: any) :: any) :: T
end

function tutility.deep_copy<T>(tbl: { [any]: any }, cache: { [any]: any }?): { [any]: any }
	cache = cache or {}

	if type(tbl) ~= "table" then
		return tbl
	end

	if (cache :: { [any]: any })[tbl] then
		return (cache :: { [any]: any })[tbl]
	end

	local shallow = tutility.shallow_copy(tbl);

	(cache :: { [any]: any })[tbl] = shallow

	for index: any, value: any in shallow do
		if type(value) ~= "table" then
			continue
		end

		shallow[index] = tutility.deep_copy(value, cache)
	end

	return shallow
end

function tutility.shallow_search<T>(tbl: { [any]: T }, predicate: (value: T, index: any) -> boolean): (T?, any?)
	for index: any, value: T in tbl do
		if predicate(value, index) then
			return value, index
		end
	end

	return
end

function tutility.deep_search<T>(
	tbl: { [any]: any },
	predicate: (value: T, index: any) -> boolean,
	cache: { [{ [any]: any }]: boolean }?
): (T?, any?, { [any]: any }?)
	cache = cache or {}

	if (cache :: { [{ [any]: any }]: boolean })[tbl] then
		return
	end

	(cache :: { [{ [any]: any }]: boolean })[tbl] = true

	for index: any, value: any in tbl do
		if predicate(value, index) then
			return value, index, tbl
		end

		if type(value) == "table" then
			local v: T?, i: any?, p: { [any]: any }? = tutility.deep_search(value, predicate, cache)

			if v then
				return v, i, p
			end
		end
	end

	return
end

function tutility.shallow_remove(tbl: { [any]: any }, target: any): boolean
	local value, index = tutility.shallow_search(tbl, function(v: any, _: any): boolean
		return target == v
	end)

	if value then
		if type(index) == "number" then
			table.remove(tbl, index)
		else
			tbl[index] = nil
		end

		return true
	end

	return false
end

function tutility.deep_remove(tbl: { [any]: any }, target: any): boolean
	local value, index, parent = tutility.deep_search(tbl, function(v: any, _: any): boolean
		return target == v
	end)

	if value then
		if type(index) == "number" then
			table.remove(parent, index)
		else
			parent[index] = nil
		end

		return true
	end

	return false
end

--// Export

return tutility
