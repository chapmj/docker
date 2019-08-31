-- Get Circumference from lua
-- Execute ! lua %

-- Read radius as input from console
-- Convert to numeric
-- Calculate circumference
-- Output result to two decimal places

function circumference_calc(radius)
	if type(radius) == (type(3)) then
		return 2 * radius * math.pi
	else 
		return nil 
	end
end

-- Console input/output 
function input_get() 
	return io.read() 
end

function output_send(str)
	if (str) then io.write(str) end
end

function number_inquire_for(str)
	output_send(str)
	input = input_get()
	return tonumber(input)
end

function calc_from_command_line(tbl) 
	-- filter input for numeric types
	-- map to numeric
	-- collect in new_tbl
	new_tbl = {}
	for v in pairs(tbl) do
		if (type(v) == (type(3))) then 
			if v then table.insert(new_tbl,tonumber(v)) end
		end
	end

	for v in pairs(new_tbl) do
		out_num = circumference_calc(v)
		output_send(string.format("%.2f\n", out_num))
	end
end

-- main start
if (#arg > 0) then
	calc_from_command_line(arg)
else
	val = number_inquire_for("\nEnter a radius: ")
	if val then
		out_num = circumference_calc(val)
		output_send(string.format("Answer: %.2f\n", out_num))
	else
		output_send("ERROR, a number was not given.")
	end
end
-- main end
