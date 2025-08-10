#!/bin/bash
echo "Running lexical analyzer on all test cases:"
for testfile in testcases/*; do
    echo "--------------------------------------------"
    echo "Test case: $testfile"
    ./lexer < "$testfile"
done

