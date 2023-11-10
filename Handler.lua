--[[
Handler

    The Handler module provides a unified approach to managing Handler-related events, states, and their interactions in Roblox using Fusion. It provides functionalities like fetching BindableEvents, managing states, subscribing to state changes, and more.

SYNOPSIS

    local HandlerInstance = Handler.new()
    local mainPageState = HandlerInstance:GetState("Page")
    print(mainPageState:get())

DESCRIPTION

    The Handler module is built to provide a clear structure for managing Handler-related events and states in Roblox. It leverages Fusion for state management and provides hooks for interfacing with BindableEvents and state changes. The module ensures that any subscribed events are cleaned up properly and provides a consistent API for interfacing with both states and events.

API

    function Handler.new(): Handler
    Creates a new Handler instance with default states and events.

    function Handler:Init()
    Initializes the Handler instance, generally by setting up necessary state listeners.

    function Handler:ListenToStates()
    Sets up observers for all the states in the Handler to listen to state changes.

    function Handler:GetEvent(SignalName: string): BindableEvent
    Fetches a BindableEvent by its name from the Handler.

    function Handler:GetState(StateName: string): Fusion.Value<any>
    Fetches the state by its name from the Handler.

    function Handler:SetState(StateName: string, Value)
    Sets the value of a specific state in the Handler.

    function Handler:SubscribeToState(StateName: string, callback: function)
    Hooks an event listener to a specific state to listen for its changes.

    function Handler:Subscribe(SignalName: string, callback: function)
    Hooks an event listener to a specific BindableEvent to execute a callback when the event is triggered.

    function Handler:Fire(SignalName: string, ...any)
    Fires a specific BindableEvent with the provided arguments.

    function Handler:DoCleaning()
    Cleans up all tasks and listeners associated with the Handler to ensure no memory leaks.

    function Handler:Destroy()
    Completely destroys the Handler instance, disconnecting all events and clearing the object.

]]

-- Implementation of Handler.

--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Fusion
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Value = Fusion.Value
local Observer = Fusion.Observer

--// Maid
local Maid = require(ReplicatedStorage.Packages.Maid)

--// Class
local Handler = {}
Handler.__index = Handler

---
-- @description Constructs a new Handler object.
-- @return Handler - The newly created Handler instance.
--
function Handler.new(Values: {
	[string]: number | string,
})
	local info = {
		--// External

		--// Internal

		--// States
		States = {},

		--// State Subscriptions
		StateSubscriptions = {},

		--// CleanUp
		_maid = Maid.new(),
	}

	for key, propValue in pairs(Values) do
		info.StateSubscriptions[key] = {}
		info.States[key] = Value(propValue)
	end

	setmetatable(info, Handler):Init()

	return info
end

---
-- @description Adds Observers for the States in the Handler.
--
function Handler:InitializeSubscriptionArrays()
	for StateName: string, State: Fusion.Value<any> in pairs(self.States) do
		local CurrentStateSubscriptionArray = self.StateSubscriptions[StateName]
		self.StateSubscriptions[StateName] = CurrentStateSubscriptionArray or {}
	end
end

---
-- @description Initializes the Handler.
--
function Handler:Init()
	self:InitializeSubscriptionArrays()
	self:ListenToStates()
end

---
-- @description Adds Observers for the States in the Handler.
--
function Handler:ListenToStates()
	-- Adding Observers
	for StateName, State: Fusion.Value<any> in pairs(self.States) do
		--// LocalStateSubscriptions
		local StateSubscriptions = self.StateSubscriptions[StateName]

		local observer = Observer(State)
		self._maid:GiveTask(observer:onChange(function()
			for _, Callback: () -> nil in pairs(StateSubscriptions) do
				Callback(State:get())
			end
		end))
	end
end

---
-- @description Fetches a desired BindableEvent from the Handler.
-- @param SignalName string - The name of the BindableEvent to fetch.
-- @return BindableEvent - The fetched BindableEvent.
--
function Handler:GetEvent(SignalName: string): BindableEvent
	local DesiredSignal: BindableEvent = self[SignalName]
	assert(DesiredSignal, "Bindable Event `" .. SignalName .. "` does not exist")

	return DesiredSignal
end

---
-- @description Fetches a desired State from the Handler.
-- @param StateName string - The name of the State to fetch.
-- @return Fusion.Value<any> - The fetched State.
--

function Handler:GetState(StateName: string): Fusion.Value<any>
	local DesiredState: Fusion.Value<any> = self.States[StateName]
	assert(DesiredState, "State `" .. StateName .. "` does not exist")

	return DesiredState
end

---
-- @description Sets a state value in the Handler.
-- @param StateName string - The name of the State to set.
-- @param Value any - The value to set the state to.
--
function Handler:SetState(StateName: string, Value): Fusion.Value<any>
	local DesiredState: Fusion.Value<any> = self:GetState(StateName)
	DesiredState:set(Value)
end

---
-- @description Hooks an event listener to a desired State.
-- @param StateName string - The name of the State to hook.
-- @param callback function - The function to execute when the event is triggered.
--
function Handler:SubscribeToState(State: string, callback: () -> nil)
	local DesiredState: Fusion.Value<any> = self:GetState(State)
	local StateSubscriptions = self.StateSubscriptions[State] or {}

	table.insert(StateSubscriptions, callback)
end

---
-- @description Hooks an event listener to a desired BindableEvent.
-- @param SignalName string - The name of the BindableEvent to hook.
-- @param callback function - The function to execute when the event is triggered.
--
function Handler:Subscribe(SignalName: string, callback: () -> nil)
	local DesiredSignal: BindableEvent = self:GetEvent(SignalName)
	self._maid:GiveTask(DesiredSignal.Event:Connect(callback))
end

---
-- @description Fires a BindableEvent with the provided arguments.
-- @param SignalName string - The name of the BindableEvent to fire.
-- @param ... any - The arguments to pass when firing the event.
--
function Handler:Fire(SignalName: string, ...)
	local DesiredSignal: BindableEvent = self:GetEvent(SignalName)
	DesiredSignal:Fire(...)
end

---
-- @description Cleans up all tasks and listeners associated with the Handler.
--
function Handler:DoCleaning()
	self._maid:Cleanup()
end

return Handler
