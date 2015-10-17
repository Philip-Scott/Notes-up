# Used for GResource.
#
# resource_dir: Directory where the .gresource.xml is located.
# resource_file: Filename of the .gresource.xml file (just the
#                filename, not the complete path).
# output_dir: Directory where the C output file is written.
# output_file: This variable will be set with the complete path of the
#              output C file.

function (gresource resource_dir resource_file output_dir output_file)
	# Get the output file path
	get_filename_component (resource_name ${resource_file} NAME_WE)
	set (output "${output_dir}/${resource_name}-resources.c")
	set (${output_file} ${output} PARENT_SCOPE)

	# Get the dependencies of the gresource
	execute_process (
		OUTPUT_VARIABLE _files
		WORKING_DIRECTORY ${resource_dir}
		COMMAND ${gresources_executable} --generate-dependencies ${resource_file}
	)

	string (REPLACE "\n" ";" files ${_files})

	set (depends "")
	foreach (cur_file ${files})
		list (APPEND depends "${resource_dir}/${cur_file}")
	endforeach ()

	# Command to compile the resources
	add_custom_command (
		OUTPUT ${output}
		DEPENDS "${resource_dir}/${resource_file}" ${depends}
		WORKING_DIRECTORY ${resource_dir}
		COMMAND ${gresources_executable} --generate-source --target=${output} ${resource_file}
	)
endfunction ()
