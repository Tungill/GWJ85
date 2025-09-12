## An Autoloads node used to make an Event Bus pattern.
## 
## Pattern using publish-subscribe-style communication between components without requiring the components to explicitly register with one another.
## Inspired by [url=https://youtu.be/yB3Wv-Lr7pg?list=PLeG_dAglpVo5oOrjQqDTMQadVDqe1Zsom]Eric Peterson's talk[/url].[br]
## [br]
## - Functions, variables and so on, should [b]never[/b] be used in this script. Only signals.[br]
# [b][/b][br]
extends Node
#class_name EventBus
@warning_ignore_start("unused_signal") # Avoid unecessary warnings in the output.
# EXAMPLE
# Use local classes to organise signals in categories.
class CategoryEvents: # This is a single category.
	signal event_happened(argument: Variant) # Signal use when an event is triggered.
	# ... other signals.
var category :CategoryEvents = CategoryEvents.new() # Be able to reference the local class to access its signals. Name the category carefully.
