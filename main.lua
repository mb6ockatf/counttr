#!/usr/bin/env lua
local argparse = require "argparse"
local mfr = require("mfr")
local use_colors, result
local repeated = 0
local right = 0
local wrong = 0

local function echo_warning(text)
	io.write(mfr.set_fg("WARNING: ", "orange", use_colors) .. text .. "\n")
end

local function echo_error(text, exit_code)
	io.write(mfr.set_fg("ERROR: ", "red", use_colors) .. text .. "\n")
	os.exit(exit_code)
end

local create_expression = {}

function create_expression:make_random_operands(range)
	local operands = {0, 0}
	operands[1] = math.random(table.unpack(range))
	operands[2] = math.random(table.unpack(range))
	if operands[1] < operands[2] then
		operands[1], operands[2] = operands[2], operands[1]
	end
	return operands
end

function create_expression:concat_expression(operands, symbol)
	local tblExpression = {tostring(operands[1]), symbol}
	table.insert(tblExpression, tostring(operands[2]))
	table.insert(tblExpression, "= ")
	return table.concat(tblExpression, " ")
end

function create_expression:squares(range)
	local parameter = math.random(table.unpack(range))
	local answer = parameter ^ 2
	local expression = self:concat_expression({parameter, 2}, "^")
	return expression, answer
end

function create_expression:add(range)
	local operands = self:make_random_operands(range)
	local answer = operands[1] + operands[2]
	local expression = self:concat_expression(operands, "-")
	return expression, answer
end

function create_expression:substract(range)
	local operands = self:make_random_operands(range)
	local answer = operands[1] - operands[2]
	local expression = self:concat_expression(operands, "-")
	return expression, answer
end

function create_expression:multiply(range)
	local operands = self:make_random_operands(range)
	local answer = operands[1] * operands[2]
	local expression = self:concat_expression(operands, "*")
	return expression, answer
end

function create_expression:floor_division(range)
	local operands = self:make_random_operands(range)
	local answer = math.floor(operands[1] / operands[2])
	local expression = self:concat_expression(operands, "//")
	return expression, answer
end

function create_expression:modulo(range)
	local operands = self:make_random_operands(range)
	local answer = operands[1] % operands[2]
	local expression = self:concat_expression(operands, "%")
	return expression, answer
end

function create_expression:cube(range)
	local parameter = math.random(table.unpack(range))
	local answer = parameter ^ 3
	local expression = self:concat_expression({parameter, 3}, "^")
	return expression, answer
end

function create_expression:power(range, power)
	local parameter = math.random(table.unpack(range))
	local answer = parameter ^ power
	local expression = self:concat_expression({parameter, power}, "^")
	return expression, answer
end

function create_expression:root(range, power)
	local parameter = math.random(table.unpack(range))
	local answer = math.floor(parameter ^ (1 / power))
	local strPower = "(1 / " .. tostring(power) .. ")"
	local expression = self:concat_expression({parameter, strPower}, "^")
	return expression, answer
end

local function train(action, range, power)
	local expression, answer
	if action == "squares" then
		expression, answer = create_expression:squares(range)
	elseif action == "cube" then
		expression, answer = create_expression:cube(range)
	elseif action == "add" then
		expression, answer = create_expression:add(range)
	elseif action == "substract" then
		expression, answer = create_expression:substract(range)
	elseif action == "multiply" then
		expression, answer = create_expression:multiply(range)
	elseif action == "floor_division" then
		expression, answer = create_expression:floor_division(range)
	elseif action == "modulo" then
		expression, answer = create_expression:modulo(range)
	elseif action == "root" then
		expression, answer = create_expression:root(range, power)
	elseif action == "power" then
		expression, answer = create_expression:power(range, power)
	end
	io.write(expression)
	local reply = io.read("*line"):lower()
	io.write('\27[A')
	io.write(string.rep('\27[C', expression:len() + reply:len()))
	if reply == "!" then
		return 2
	end
	if tonumber(reply) == answer then
		return 0
	else
		return 1
	end
end

local function check_arguments(arguments)
	if arguments["repeat"] < 1 then
		echo_error("'repetitions' is smaller than 1", 128)
	elseif arguments.from and arguments.to then
		if arguments.to <= arguments.from then
			echo_error("'to' is smaller or equal to 'from'", 128)
		end
	end
	if mfr.belongs(arguments.action, {"root", "multiply"}) then
		if not arguments.power then
			echo_error("'power' argument is required", 128)
		end
		if arguments.power < 0 then
			echo_error("'power' smaller than 1", 128)
		end
	end
end

local parser = argparse()
	:name "counttr"
	:description "mathematics count trainer"
	:epilog "https://github.com/mb6ockatf/counttr"
	:add_complete()
parser:argument "action"
	:choices {"squares", "add", "multiply", "substract", "floor_division",
		"root", "power", "modulo"}
	:description "training mode"
parser:option "--repeat"
	:description "number of repetitions"
	:default(24)
	:convert(tonumber)
parser:option "--from"
	:description "smaller range border"
	:convert(tonumber)
parser:option("--to")
    :description "larger range border"
	:convert(tonumber)
parser:option("--power")
	:description "power for power action or root"
	:convert(tonumber)
parser:flag("-n --no-colors",
	"disable use of colorful output with ascii control sequences")
parser:flag("-c --colors",
	[[(forced) use of colorful output with ascii control sequences
by default, colors are enabled if NO_COLORS environment variable is not set
and terminal emulator supports colors.]])
local args = parser:parse()
if args.colors then
	use_colors = true
elseif args.no_colors then
	use_colors = false
end
math.randomseed(os.time() + tonumber(tostring({}):sub(8)))
if args.to and not args.from then
	args.from = (args.to - 200) % 1 + 1
elseif not args.to and args.from then
	args.to = args.from + 200
end
if not args.to and not args.from then
	args.to, args.from = 256, 32
end

check_arguments(args)
while repeated ~= args["repeat"] do
	result = train(args.action, {args.from, args.to}, args.power)
	if result == 0 then
		right = right + 1
		io.write(mfr.set_fg("  # right", "green") .. "\n")
	elseif result == 1 then
		wrong = wrong + 1
		io.write(mfr.set_fg("  # wrong", "red") .. "\n")
	elseif result == 2 then
		io.write("\n")
		echo_warning("only " .. tostring(repeated) .. " questions completed")
		repeated = args["repeat"] - 1
	end
	repeated = repeated + 1
end
io.write(tostring(repeated) .. ": ")
io.write(mfr.set_fg(tostring(right), "green") .. "/")
io.write(mfr.set_fg(tostring(wrong), "red") .. "/")
io.write(mfr.set_fg(tostring(repeated - right - wrong), "blue") .. "\n")