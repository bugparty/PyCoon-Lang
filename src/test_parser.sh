#!/bin/bash
make clean
make
# cat ../doc/language_samples/test_cases/passing/while_loop.onion | ./onion
# cat ../doc/language_samples/parser/03while01.onion | ./onion
# cat ../doc/language_samples/parser/04expr_assign.onion | ./onion
cat ../doc/language_samples/parser/05while02.onion | ./onion
cat ../doc/language_samples/parser/06Ifelse.onion | ./onion