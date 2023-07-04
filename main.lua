#!/usr/bin/env lua
local SUPPORT_COLORS = false
local HELP = [[
counttr - mathematics trainer

USAGE: lua main.lua [ --repeat] [number]
	                [ --from] number
	                [ --to] number
	                [ --action] squares (only squares yet)
	                [ --help] outputs this message
]]
local args, entropy, repetitions = {...}, 0, 1
local from, to, temp, action


local function execute_system_command(command)
	local handle = io.popen(command)
	local output = handle:read("*a")
	handle:close()
	return output
end

local function get_terminal_colors_number()
	local colors_number = tonumber(execute_system_command("tput colors"))
	if colors_number == nil then
		return 0
	else
		return colors_number
	end
end


local function echo_warning(text)
	local text = "WARNING: " .. text
	if SUPPORT_COLORS == true then
		text = "\27[33m" .. text .. "\27[39m"
	end
	io.write(text .. "\n")
end

local function echo_error(text, exit_code)
	local text = "ERROR: " .. text
	if SUPPORT_COLORS == true then
		text = "\27[31m" .. text .. "\27[39m"
	end
	io.write(text .. "\n")
	os.exit(exit_code)
end

local function train_squares(range_start, range_finish, repetitions)
	local correct = 0
	for iter = 1, repetitions, 1 do
		::continue::
		local argument = math.random(range_start, range_finish)
		io.write(argument .. " ^ 2 = ")
		local answer = io.read("*line"):lower()
		if answer == "!" then
			goto end_train
		end
		local answer = tonumber(answer)
		if answer == nil then
			echo_warning("your input was not recongnised")
			goto continue
		end
		if answer == argument ^ 2 then
			io.write(" | correct\n")
			correct = correct + 1
		else
			io.write(" | wrong\n")
		end
	end
	::end_train::
	return correct, repetitions
end

math.randomseed(os.time() + tonumber(tostring({}):sub(8)))
if get_terminal_colors_number() >= 16 then
	SUPPORT_COLORS = true
end
if #args == 0 then
	io.write(HELP)
end
for index, value in ipairs(args) do
	if value == "--repeat" then
		temp = tonumber(args[index + 1])
		if temp ~= nil then
			repetitions = temp
		else
			repetitions = true
		end
	elseif value == "--from" then
		temp = tonumber(args[index + 1])
		if temp ~= nil then
			from = temp
		else
			echo_warning("--from parameter is not correct")
		end
	elseif value == "--to" then
		temp = tonumber(args[index + 1])
		if temp ~= nil then
			to = temp
		else
			echo_warning("--to parameter is not correct")
		end
	elseif value == "--action" then
		temp = args[index + 1]
		if temp == "squares" then
			action = temp
		else
			echo_warning("--action parameter is not correct")
		end
	elseif value == "--help" or value == "-h" then
		io.write(help)
	end
end
if repetitions < 1 then
	echo_error("'repetitions' is smaller than 1", 128)
elseif from ~= nil and to ~= nil then
	if to <= from then
		echo_error("'to' is smaller or equal to 'from'", 128)
	end
end
if from == nil and to == nil then
	from, to = 0, 0
	while not (to - from < 100) do
		from, to = math.random(), math.random()
	end
elseif from == nil and to ~= nil then
	from = to - 100
elseif from ~= nil and to == nil then
	to = from + 100
end
if action == "squares" then
	train_squares(from, to, repetitions)
end
