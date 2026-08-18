extends Node



var kit_script_start = 'import time\nfrom user.library import DroneLibrary\ndrone = DroneLibrary()\n
drone.start()\n'
var kit_script_end = '\ndrone.stop()'
var python_script: String = ''

var piranya_script_start = '#include <Piranha.h>

void DroneSetup(void)
{
	
}

void DroneLoop(void)
{
	bot::MotorEnable();
	move::Reset();
	bot::FixCourse();
	bot::FixDepth();
	WaitMs(500);

'
var piranya_script_end = '
	bot::MotorDisable();
}'
var arduino_script = ''

var tabs_coef = 0

func code_program(blocks: Array[ProgramBlock]) -> String:
	if DroneToProgram.current_drone == DroneToProgram.Drone.kit:
		python_script = kit_script_start
		tabs_coef = 0
		for block in blocks:
			python_match_block_type(block)
		python_script += kit_script_end
		print(python_script)
		return python_script
	elif DroneToProgram.current_drone == DroneToProgram.Drone.piranya:
		arduino_script = piranya_script_start
		tabs_coef = 1
		for block in blocks:
			arduino_match_block_type(block)
		arduino_script += piranya_script_end
		print(arduino_script)
		return arduino_script
	return ''

func arduino_match_block_type(block):
	if block is Block:
		arduino_script += '\t'.repeat(tabs_coef) + block.set_code_line + '(' + str(block.value) + ');\n'
	elif block is BlockWithTime:
		arduino_script += '\t'.repeat(tabs_coef) + block.set_code_line + '(' + str(block.value) + ',' + str(block.time_value) + ');\n'
	elif block is BlockWithoutValue:
		arduino_script += '\t'.repeat(tabs_coef) + block.set_code_line + ';\n'
	elif block is CycleBlock:
		block.do_cycle_array()
		arduino_script += '\t'.repeat(tabs_coef) + block.code_lines[int(block.current_cycle)]
		if block.current_cycle == block.CycleType.count:
			arduino_script += ' i < ' + str(block.repeats_count) + '; i++) {\n'
		else:
			arduino_script += ' {\n'
		tabs_coef += 1
		for b in block.cycle_array:
			arduino_match_block_type(b)
		tabs_coef -= 1
		arduino_script += '\t'.repeat(tabs_coef) + '}\n'

func python_match_block_type(block):
	if block is Block:
		if block.has_type:
			match block.current_type:
				block.CommandType.SET:
					python_script += block.set_code_line + '(' + str(block.value) + ')\n'
				block.CommandType.CHANGE:
					python_script += block.change_code_line + '(' + str(block.value) + ')\n'
		else:
			python_script += block.set_code_line + '(' + str(block.value) + ')\n'

	elif block is CycleBlock:
		tabs_coef += 1
		block.do_cycle_array()
		print('code_lines: ', block.code_lines)
		python_script += block.code_lines[int(block.current_cycle)]
		if block.current_cycle == block.CycleType.count:
			python_script += '(' + str(block.repeats_count) + '):\n'
		else:
			python_script += ':\n'
		for b in block.cycle_array:
			python_script += '	'.repeat(tabs_coef)
			python_match_block_type(b)
		tabs_coef -= 1

	elif block is ConditionBlock:
		block.do_arrays()
		print('code_lines: ', block.code_lines)
		if block.if_array != []:
			tabs_coef += 1
			python_script += 'if ' + block.param1_dict[block.param1_value] + block.sign + str(block.param2_value) + ':\n'
			for b in block.if_array:
				python_script += '	'.repeat(tabs_coef)
				python_match_block_type(b)

			if block.else_array != []:
				python_script += '	'.repeat(tabs_coef - 1) + 'else:\n'
				for b in block.else_array:
					python_script += '	'.repeat(tabs_coef)
					python_match_block_type(b)
			tabs_coef -= 1
		
