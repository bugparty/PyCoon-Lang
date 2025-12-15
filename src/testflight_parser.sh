#!/usr/bin/env bash
make clean
make -j`nproc`
error=$?
if [ "$error" -ne 0 ]; then
	echo -e "\e[31m!!!!!!!!Error in make onion,stop testing.!!!!!!!!!! \e[0m"
	exit -1
else
	echo -e "\e[32mMake succeed! \e[0m"
fi
# cat ../doc/language_samples/test_cases/passing/while_loop.pyco | ./onion
# cat ../doc/language_samples/parser/03while01.pyco | ./onion
# cat ../doc/language_samples/parser/04expr_assign.pyco | ./onion
# cat ../doc/language_samples/parser/07for.pyco | ./onion
# cat ../doc/language_samples/parser/05while02.pyco | ./onion
# cat ../doc/language_samples/parser/06Ifelse.pyco | ./onion
# cat ../doc/language_samples/parser/11IfElse2.pyco | ./onion
# cat ../doc/language_samples/parser/12ifElse_additional_testing.pyco | ./onion
# cat ../doc/language_samples/IR_test_case/2expr.pyco | ./onion
# cat tests/IR_auto_tests/function01.pyco | ./onion -p
#cat tests/IR_auto_tests/a_plus_b.pyco | ./onion
#cat ../doc/language_samples/IR_test_case/if03.pyco | ./onion
#cat tests/IR_auto_tests/2expr.pyco | ./onion
#cat ../doc/language_samples/IR_test_case/while_break.pyco | ./onion
cat tests/IR_auto_tests/2expr.pyco | ./onion
