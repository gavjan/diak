# Excercise 1

# Diakrytynizator

Implement in x86_64 assembly language a program that reads text from standard input, modifies it in the following
described method, and write the result to the standard output. We use UTF-8 to encode the text, see
https://pl.wikipedia.org/wiki/UTF-8. The program does not change characters with unicode values between `0x00` and `0x7F`.
On the other hand, each character with a unicode value greater than `0x7F` transforms into a character whose unicode value is determined
using the polynomial described below.

# Diacritization polynomial

The diacritinizing polynomial is defined by the parameters for inducing the diacritinator:
```sh
./diakrytynizator a0 a1 a2 ... an
```
as:
```
w(x) = an * x^n + ... + a2 * x^2 + a1 * x + a0
```

The coefficients of the polynomial are non-negative integers given in base ten. Must occur
at least the `a0` parameter.

Calculation of the polynomial value is done modulo `0x10FF80`. In the text, the unicode `x` is replaced
character with unicode value `w (x - 0x80) + 0x80`.

# Program termination and error handling

The program acknowledges correct termination of operation, returning the code `0`. When an error is detected, the program exits by returning
code `1`.

The program should validate call parameters and input data. We assume that it is correct
are UTF-8 characters with unicode values from `0` to`0x10FFFF`, encoded with at most `4` bytes and is only valid
the shortest possible write method.

# Usage examples

Input
```sh
echo "Zażółć gęślą jaźń..." | ./diakrytynizator 0 1; echo $?
```
writes out
```
Zażółć gęślą jaźń...
0
```
Input
```sh
echo "Zażółć gęślą jaźń..." | ./diakrytynizator 133; echo $?
```
writes out
```
Zaąąąą gąąlą jaąąą
0
```
Input
```sh
echo "ŁOŚ" | ./diakrytynizator 1075041 623420 1; echo $?
```

writes out

```
„O”
0
```
Input
```sh
echo -e "abc\n\x80" | ./diakrytynizator 7; echo $?
```
writes out
```
abc
1
```

# Compile

```sh
nasm -f elf64 -w+all -w+error -o diakrytynizator.o diakrytynizator.asm
ld --fatal-warnings -o diakrytynizator diakrytynizator.o
```
