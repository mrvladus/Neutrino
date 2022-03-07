extends Node

# Languages
onready var languages: Dictionary = {
	'Python' : {
		'extensions' : ['py'],
		'keywords' : ['False', 'None', 'True', 'and', 'as', 'assert', 'async', 'await', 'break', 'class', 'continue', 'def', 'del', 'elif', 'else', 'except', 'finally', 'for', 'from', 'global', 'if', 'import', 'in', 'is', 'lambda', 'nonlocal', 'not', 'or', 'pass', 'raise', 'return', 'self', 'str', 'try', 'while', 'with', 'yield'],
		'sl_comment' : '#'
	},
	'Bash' : {
		'extensions' : ['sh', 'bashrc', 'bash_profile'],
		'keywords' : ['if', 'then', 'else', 'elif', 'fi', 'case', 'esac', 'for', 'select', 'while', 'until', 'do', 'done', 'in', 'function', 'time', '{', '}', '!', '[[', ']]', 'coproc'],
		'sl_comment' : '#'
	}
}

# Brackets
onready var start_symbols: Array = ['(', '[', '{', '<', '"', "'"]
onready var end_symbols: Array = [')', ']', '}', '>', '"', "'"]
