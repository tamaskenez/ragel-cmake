set(ragel_SOURCES
	buffer.h cdgoto.h cscodegen.h csipgoto.h inputdata.h rbxgoto.h
	rubyflat.h cdcodegen.h cdipgoto.h csfflat.h cssplit.h javacodegen.h
	redfsm.h rubyftable.h cdfflat.h cdsplit.h csfgoto.h cstable.h
	parsedata.h rlparse.h rubytable.h cdfgoto.h cdtable.h csflat.h
	dotcodegen.h parsetree.h rlscan.h version.h cdflat.h common.h
	csftable.h fsmgraph.h pcheck.h rubycodegen.h xmlcodegen.h cdftable.h
	csgoto.h gendata.h ragel.h rubyfflat.h
	gocodegen.h gotable.h goftable.h goflat.h gofflat.h gogoto.h gofgoto.h
	goipgoto.h gotablish.h
	mlcodegen.h mltable.h mlftable.h mlflat.h mlfflat.h mlgoto.h mlfgoto.h
	main.cpp parsetree.cpp parsedata.cpp fsmstate.cpp fsmbase.cpp
	fsmattach.cpp fsmmin.cpp fsmgraph.cpp fsmap.cpp rlscan.cpp rlparse.cpp
	inputdata.cpp common.cpp redfsm.cpp gendata.cpp cdcodegen.cpp
	cdtable.cpp cdftable.cpp cdflat.cpp cdfflat.cpp cdgoto.cpp cdfgoto.cpp
	cdipgoto.cpp cdsplit.cpp javacodegen.cpp rubycodegen.cpp rubytable.cpp
	rubyftable.cpp rubyflat.cpp rubyfflat.cpp rbxgoto.cpp cscodegen.cpp
	cstable.cpp csftable.cpp csflat.cpp csfflat.cpp csgoto.cpp csfgoto.cpp
	csipgoto.cpp cssplit.cpp dotcodegen.cpp xmlcodegen.cpp
	gocodegen.cpp gotable.cpp goftable.cpp goflat.cpp gofflat.cpp gogoto.cpp gofgoto.cpp
	goipgoto.cpp gotablish.cpp
	mlcodegen.cpp mltable.cpp mlftable.cpp mlflat.cpp mlfflat.cpp mlgoto.cpp mlfgoto.cpp
)

file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/include/version.h
	"#define VERSION \"${VERSION}\"\n"
	"#define PUBDATE \"${PUBDATE}\"\n")

if(NOT CMAKE_STATIC_LIBRARY_PREFIX)
	set(CMAKE_STATIC_LIBRARY_PREFIX lib)
endif()

add_executable(ragel ${ragel_SOURCES})
target_include_directories(ragel PRIVATE
	${CMAKE_CURRENT_BINARY_DIR}/include
	${PROJECT_BINARY_DIR}/include
	${PROJECT_SOURCE_DIR}/aapl
)
target_compile_definitions(ragel PRIVATE HAVE_CONFIG_H)
set_target_properties(ragel PROPERTIES DEBUG_POSTFIX _d)
install(TARGETS ragel EXPORT ragel-targets DESTINATION bin)
install(EXPORT ragel-targets FILE ragel-config.cmake DESTINATION lib/cmake/ragel)

#[=[

BUILT_SOURCES = \
	rlscan.cpp rlparse.h rlparse.cpp version.h

EXTRA_DIST = rlscan.rl rlparse.kh rlparse.kl

]=]
