PROJECT_NAME = Project5
RUN_ARGS = TestIn.txt TestOut.txt

COMPILER = g++
COMP_FLAGS = -w -d -Wall -g -std=c++11 -c -o
LINK_FLAGS = -Wall -g -std=c++11 -o

SRC_FILE_TYPE = .cpp
HEAD_FILE_TYPE = .h
BIN_FILE_TYPE = .o

BIN_DIR = obj/
SRC_DIR = ./

MAX_COMPLEXITY = 8
TEST_FILE_DIR = tests/
TEST_FILE_TYPE = .txt
IN_FILE_PREFIX = in
OUT_FILE_PREFIX = out

SHELL = /bin/bash


src_files := $(wildcard $(SRC_DIR)*$(SRC_FILE_TYPE))
bin_files := $(addprefix $(BIN_DIR),$(notdir $(src_files:$(SRC_FILE_TYPE)=$(BIN_FILE_TYPE))))
in_files := $(wildcard $(TEST_FILE_DIR)$(IN_FILE_PREFIX)*$(TEST_FILE_TYPE))


pre-build :
	@clear
	@clear
	@$(MAKE) --no-print-directory $(PROJECT_NAME)

$(PROJECT_NAME) : $(bin_files) config
	$(COMPILER) $(LINK_FLAGS) $@ $^

$(BIN_DIR)%$(BIN_FILE_TYPE): $(SRC_DIR)%$(SRC_FILE_TYPE) 
	@mkdir -p $(BIN_DIR)
	$(COMPILER) $(COMP_FLAGS) $@ $<

clean :
	-rm -r -f $(PROJECT_NAME) $(BIN_DIR)

run : pre-build
	./$(PROJECT_NAME) $(RUN_ARGS)

val : pre-build
	valgrind --leak-check=full ./$(PROJECT_NAME) $(RUN_ARGS)

complex :
	@clear
	@clear
	pmccabe $(SRC_DIR)*$(HEAD_FILE_TYPE) $(SRC_DIR)*$(SRC_FILE_TYPE)

zip :
	zip $(PROJECT_NAME).zip $(SRC_DIR)*$(HEAD_FILE_TYPE) $(SRC_DIR)*$(SRC_FILE_TYPE)


.PHONY : zip pre-build complex run clean test config
	
.ONESHELL : 
	

test : pre-build
	@mkdir -p $(TEST_FILE_DIR); \
	PMCCABE_OUTPUT=`pmccabe $(SRC_DIR)*$(HEAD_FILE_TYPE) $(SRC_DIR)*$(SRC_FILE_TYPE) | grep -e '^[^0-$(MAX_COMPLEXITY)]\s' -e '^[0-9][0-9]'`; \
	if [[ $$PMCCABE_OUTPUT ]]; then \
		echo "$$PMCCABE_OUTPUT"; \
		echo pmccabe complexity to high; \
		exit 1; \
	fi; \
	echo pmccabe complexity test passed; \
	for inFilePath in $(in_files); \
	do \
		outFile=$(TEST_FILE_DIR)$(OUT_FILE_PREFIX)$${inFilePath#$(TEST_FILE_DIR)$(IN_FILE_PREFIX)}; \
		valgrind --error-exitcode=1 --leak-check=full ./$(PROJECT_NAME) $$inFilePath $(TEST_FILE_DIR)$(PROJECT_NAME)-TEST-OUT$(TEST_FILE_TYPE) > $(TEST_FILE_DIR)valgrindOutput.txt 2>&1; \
		if [ "$$?" = "1" ]; then \
			cat $(TEST_FILE_DIR)valgrindOutput.txt; \
			echo valgrind error; \
			rm -f $(TEST_FILE_DIR)valgrindOutput.txt; \
			exit 1; \
		fi; \
		echo valgrind memory test passed for input file $$inFilePath; \
		FILE_COMP=`diff --unchanged-line-format="" --old-line-format="" --new-line-format=":%dn: %L" --strip-trailing-cr $(TEST_FILE_DIR)$(PROJECT_NAME)-TEST-OUT$(TEST_FILE_TYPE) $$outFile`; \
		if [[ $$FILE_COMP ]]; then \
			echo "$$FILE_COMP"; \
			echo output does not match $$outFile; \
			rm -f $(TEST_FILE_DIR)valgrindOutput.txt; \
			rm -f $(TEST_FILE_DIR)$(PROJECT_NAME)-TEST-OUT$(TEST_FILE_TYPE); \
			exit 1; \
		fi; \
		echo file output matches for $$outFile; \
	done; \
	rm -f $(TEST_FILE_DIR)valgrindOutput.txt; \
	rm -f $(TEST_FILE_DIR)$(PROJECT_NAME)-TEST-OUT$(TEST_FILE_TYPE); \
	zip $(PROJECT_NAME).zip $(SRC_DIR)*$(HEAD_FILE_TYPE) $(SRC_DIR)*$(SRC_FILE_TYPE); \
	echo Finished: all tests passed; \

	
