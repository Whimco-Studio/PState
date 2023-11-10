--[[
PState

    A short description of the module.

SYNOPSIS

    -- Lua code that showcases an overview of the API.
    local foobar = PState.TopLevel('foo')
    print(foobar.Thing)

DESCRIPTION

    A detailed description of the module.

API

    -- Describes each API item using Luau type declarations.

    -- Top-level functions use the function declaration syntax.
    function ModuleName.TopLevel(thing: string): Foobar

    -- A description of Foobar.
    type Foobar = {

        -- A description of the Thing member.
        Thing: string,

        -- Each distinct item in the API is separated by \n\n.
        Member: string,

    }
]]

-- Implementation of PState.

--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Modules
local Handler = require(script.Handler)

--// Class
local PState = {}
PState.__index = PState

function PState.new()
	local info = {
		PStates = {},
		Connections = {},
	}
	setmetatable(info, PState)
	return info
end

function PState:Set(
	FSMName: string,
	Values: {
		[string]: number | string,
	}
): typeof(Handler.new())
	print(FSMName, Values)
	self.PStates[FSMName] = Handler.new(Values)

	return self.PStates[FSMName]
end

return PState.new()
