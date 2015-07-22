file(GLOB test_cases RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_CURRENT_SOURCE_DIR}/*.rl)

foreach(test_case ${test_cases})
	set(root "${test_case}")
	string(REGEX REPLACE "[.]rl$" "" root "${root}")

	file(STRINGS ${CMAKE_CURRENT_SOURCE_DIR}/${test_case} tc_str)
	if(tc_str MATCHES "@IGNORE:[ \t]*yes([ \t;]|$)")
		continue()
	endif()

	set(expected_out "${CMAKE_CURRENT_BINARY_DIR}/${root}.exp")
	string(REGEX MATCH "_____OUTPUT_____[ \t]*;(.*)" _ "${tc_str}")
	set(expected_out_str "${CMAKE_MATCH_1}")
	if(expected_out_str MATCHES ";$")
		string(REGEX REPLACE ";$" "" expected_out_str "${expected_out_str}")
	else()
		string(REGEX REPLACE "(^|;)[^;]+$" "" expected_out_str "${expected_out_str}")
	endif()
	string(REPLACE ";" "\n" expected_out_str "${expected_out_str}")
	file(WRITE ${expected_out} "${expected_out_str}\n")

	string(REGEX MATCH "@LANG:[ \t]([^; \t]*)" _ "${tc_str}")
	set(lang "${CMAKE_MATCH_1}")
	if(NOT lang)
		message(FATAL_ERROR "${test_case}: language unset")
	endif()

	if(lang STREQUAL "c++")
		set(code_suffix "cpp")
		set(lang_opt "-C")
	elseif(lang STREQUAL "c")
		set(code_suffix "c")
		set(lang_opt "-C")
	else()
		continue()
	endif()

	set(code_src ${root}.${code_suffix})

	string(REGEX MATCH "@CFLAGS:[ \t]([^; \t]*)" _ "${tc_str}")
	set(additional_cflags "${CMAKE_MATCH_1}")
	separate_arguments(additional_cflags UNIX_COMMAND "${additional_cflags}")
	set(additional_include_dirs "")
	foreach(cflag ${additional_cflags})
		if(cflag MATCHES "^-I(.+)")
			list(APPEND additional_include_dirs "${CMAKE_CURRENT_SOURCE_DIR}/${CMAKE_MATCH_1}")
		endif()
	endforeach()

	string(REGEX MATCH "@ALLOW_MINFLAGS:[ \t]([^; \t]*)" _ "${tc_str}")
	if(CMAKE_MATCH_1 STREQUAL "")
		set(allow_minflags "-n -m -l -e")
	else()
		set(allow_minflags "${CMAKE_MATCH_1}")
	endif()
	separate_arguments(allow_minflags)

	string(REGEX MATCH "@ALLOW_GENFLAGS:[ \t]([^; \t]*)" _ "${tc_str}")
	if(CMAKE_MATCH_1 STREQUAL "")
		set(allow_genflags "-T0 -T1 -F0 -F1 -G0 -G1 -G2")
	else()
		set(allow_genflags "${CMAKE_MATCH_1}")
	endif()
	separate_arguments(allow_genflags)

	set(TEST_BINARY_DIR "${CMAKE_CURRENT_BINARY_DIR}/test-build")
	set(TEST_SOURCE_DIR "${CMAKE_CURRENT_BINARY_DIR}/test-src")
	file(MAKE_DIRECTORY "${TEST_BINARY_DIR}")
	file(MAKE_DIRECTORY "${TEST_SOURCE_DIR}")
	file(WRITE "${TEST_SOURCE_DIR}/CMakeLists.txt" "
		cmake_minimum_required(VERSION ${CMAKE_VERSION})
		project(ragel-test)
		add_executable(test-exe \${TEST_CODE_SRC})
		if(TEST_INCLUDE_DIR_SCRIPT)
			include(\"\${TEST_INCLUDE_DIR_SCRIPT}\")
		endif()
		target_include_directories(test-exe PRIVATE \"\${TEST_CASE_SOURCE_DIR}\")
		install(TARGETS test-exe DESTINATION bin)
		")

	if(additional_include_dirs)
		set(s "")
		foreach(d ${additional_include_dirs})
			set(s "${s}target_include_directories(test-exe PRIVATE \"${d}\"\n)")
		endforeach()
		set(include_dir_script_file "${CMAKE_CURRENT_BINARY_DIR}/include-dir-script-${root}.cmake")
		file(WRITE "${include_dir_script_file}" "${s}")
	else()
		set(include_dir_script_file "")
	endif()

	foreach(min_opt ${allow_minflags})
		foreach(gen_opt ${allow_genflags})
			set(name "test-${root}${lang_opt}${min_opt}${gen_opt}")
			if(include_dir_script_file)
				set(include_dir_option "-DTEST_INCLUDE_DIR_SCRIPT=${include_dir_script_file}")
			else()
				set(include_dir_option "-DTEST_INCLUDE_DIR_SCRIPT=")
			endif()
			add_test(
				NAME "${name}"
				COMMAND ${CMAKE_COMMAND}
					-DTEST_BINARY_DIR=${TEST_BINARY_DIR}
					-DTEST_CODE_SRC=${CMAKE_CURRENT_BINARY_DIR}/${code_src}
					-DRAGEL_EXECUTABLE=$<TARGET_FILE:ragel>
					-DTEST_CASE_SOURCE_DIR=${CMAKE_CURRENT_SOURCE_DIR}
					-DTEST_CONFIG=$<CONFIG>
					-DTEST_NAME=${name}
					-Dlang_opt=${lang_opt}
					-Dmin_opt=${min_opt}
					-Dgen_opt=${gen_opt}
					-Dtest_case=${test_case}
					-DTEST_SOURCE_DIR=${TEST_SOURCE_DIR}
					-DTEST_EXPECTED_OUT=${expected_out}
					${include_dir_option}
					-P ${CMAKE_CURRENT_SOURCE_DIR}/test-driver.cmake
			)
		endforeach()
	endforeach()
endforeach()





#[=[
TESTS = runtests

EXTRA_DIST = \
	atoi1.rl clang2.rl cond7.rl element3.rl erract8.rl forder3.rl java1.rl \
	range.rl scan3.rl xml.rl atoi2.rl clang3.rl cppscan1.rl eofact.rl \
	erract9.rl gotocallret1.rl java2.rl recdescent1.rl scan4.rl atoi3.rl \
	clang4.rl cppscan2.rl erract1.rl export1.rl gotocallret2.rl keller1.rl \
	recdescent2.rl stateact1.rl awkemu.rl cond1.rl cppscan3.rl erract2.rl \
	export2.rl high1.rl lmgoto.rl recdescent3.rl statechart1.rl builtin.rl \
	cond2.rl cppscan4.rl erract3.rl export3.rl high2.rl mailbox1.rl \
	repetition.rl strings1.rl call1.rl cond3.rl cppscan5.rl erract4.rl \
	export4.rl high3.rl mailbox2.rl rlscan.rl strings2.rl call2.rl cond4.rl \
	cppscan6.rl erract5.rl fnext1.rl import1.rl mailbox3.rl ruby1.rl \
	tokstart1.rl call3.rl cond5.rl element1.rl erract6.rl forder1.rl \
	include1.rl minimize1.rl scan1.rl union.rl clang1.rl cond6.rl \
	element2.rl erract7.rl forder2.rl include2.rl patact.rl scan2.rl \
	xmlcommon.rl langtrans_c.sh langtrans_csharp.sh langtrans_d.sh \
	langtrans_java.sh langtrans_ruby.sh checkeofact.txl \
	langtrans_csharp.txl langtrans_c.txl langtrans_d.txl langtrans_java.txl \
	langtrans_ruby.txl testcase.txl cppscan1.h eofact.h mailbox1.h strings2.h

CLEANFILES = \
	*.c *.cpp *.m *.d *.java *.bin *.class *.exp \
	*.out *_c.rl *_d.rl *_java.rl *_ruby.rl *_csharp.rl *.cs \
	*_go.rl *.go *.exe
]=]
