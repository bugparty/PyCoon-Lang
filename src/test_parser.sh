#!/bin/bash
make clean
make -j`nproc`
error=$?
if [ "$error" -ne 0 ]; then
echo -e "\e[31m!!!!!!!!Error in make onion,stop testing.!!!!!!!!!! \e[0m"
exit -1
else
echo -e "\e[32mMake succeed! \e[0m"
fi
# cat ../doc/language_samples/test_cases/passing/while_loop.onion | ./onion
# cat ../doc/language_samples/parser/03while01.onion | ./onion
# cat ../doc/language_samples/parser/04expr_assign.onion | ./onion
# cat ../doc/language_samples/parser/07for.onion | ./onion
# cat ../doc/language_samples/parser/05while02.onion | ./onion
# cat ../doc/language_samples/parser/06Ifelse.onion | ./onion
# cat ../doc/language_samples/parser/11IfElse2.onion | ./onion
# cat ../doc/language_samples/parser/12ifElse_additional_testing.onion | ./onion
#cat ../doc/language_samples/IR_test_case/2expr.onion | ./onion
# cat tests/IR_auto_tests/function01.onion | ./onion -p
#cat tests/IR_auto_tests/a_plus_b.onion | ./onion
#cat ../doc/language_samples/IR_test_case/if03.onion | ./onion
#cat tests/IR_auto_tests/2expr.onion | ./onion
#cat ../doc/language_samples/IR_test_case/while_break.onion | ./onion
cat tests/IR_auto_tests/while03.onion | ./onion