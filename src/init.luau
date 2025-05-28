--// tutility

local tutility = {}

--// Public

function tutility.shallow<T>(tbl: T): T
	return (table.clone(tbl :: any) :: any) :: T
end

function tutility.deep<T>(tbl: T, cache: { [any]: any }?): T
	cache = cache or {}

	if type(tbl) ~= "table" then
		return tbl
	end

	if (cache :: { [any]: any })[tbl] then
		return (cache :: { [any]: any })[tbl]
	end

	local shallow = tutility.shallow(tbl);

	(cache :: { [any]: any })[tbl] = shallow

	for index: any, value: any in shallow do
		if type(value) ~= "table" then
			continue
		end

		shallow[index] = tutility.deep(value, cache)
	end

	return shallow
end

function tutility.foreach(tbl: { [any]: any }, callback: (index: any, value: any) -> ...any)
	if type(tbl) ~= "table" then
		return
	end

	if type(callback) ~= "function" then
		return
	end

	for index: any, value: any in tbl do
		task.spawn(pcall, callback, index, value)
	end
end

--// Export

return tutility
