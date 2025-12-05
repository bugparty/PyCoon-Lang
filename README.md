# 🦝 PyCoon  Programming Language
Author: [Bowen Han](https://github.com/bugparty), [Yuze Fu](https://github.com/fuyuze123), [Kevin Qu](https://github.com/KevinDevs), [Haosheng Long](https://github.com/hlonglhs).

## CI Test Result

[![CI WorkFLow](https://github.com/bugparty/PyCoon-Lang/actions/workflows/ci.yml/badge.svg 'CI Workflow')](https://github.com/bugparty/PyCoon-Lang/actions)

[![CI WorkFLow](https://github.com/bugparty/PyCoon-Lang/actions/workflows/unittest.yml/badge.svg 'CI Workflow')](https://github.com/bugparty/PyCoon-Lang/actions)

**“Steals Python’s syntax. Fights crime with C logic.”**

*A toy language that looks Pythonic… but acts like C.*


---


## 🧁 Overview


**PyCoon** is a mischievous little programming language:

it **borrows** Python’s clean syntax but **runs** with C’s semantics and execution model.


Think of it as a raccoon in a Python costume — cute indentation on the outside, raw C metal inside.


### Core ideas


- 🐍 **Python-style syntax** (indentation, `def`, `for`, `:`)
- ⚙️ **C-style semantics** (static types, values-as-lvalues, C ABI)
- 🚀 **Compiled** into C or LLVM IR
- 😂 **Funny but functional** toy language
- 🦝 **Raccoon-coded**: steals syntax, keeps the shiny bits, throws away the rest


Use PyCoon when you want to:


- Build compiler assignments / toy interpreters
- Prototype DSLs
- Write Python but secretly want C
- Add chaos to your project
- Pay tribute to *South Park’s* Coon


---


## 🦝 Lore (The Language Backstory)


Legend says a raccoon once broke into the Python warehouse at night.


It stole:


- indentation
- `def`
- `return`
- colons
- `for` loops
- the entire “pythonic vibe”


But it ignored Python’s runtime — because raccoons like **metal**, not virtual machines.


So it stitched everything onto a pure C engine.


And thus, **PyCoon** was born:


>
> **Python on the outside. C in the heart. Raccoon in the soul.**
>
>
>


---


## 🚀 Installation


*(Assumes you have a simple compiler implementation in the repository.)*


### Clone


```bash
git clone https://github.com/bugparty/PyCoon-Lang.git
cd PyCoon-Lang

```


### Build


```bash
make

```


### Run


```bash
./pyc main.pcn

```


We use `.pcn` as the official file extension

(**P**y**C**oo**N**).


---


## 🧪 Hello World


### PyCoon source


```python
def main():
    print("Hello from PyCoon!")

```


### Generated C (example)


```c
int main() {
    printf("Hello from PyCoon!\n");
    return 0;
}

```


---


## 📘 Language Basics


### ✔️ Variables are statically typed


Even though syntax looks Pythonic, PyCoon enforces C-style types.


```python
let x: int = 5
let y: float = 3.14

```


### ✔️ Functions look Pythonic


But types behave like C.


```python
def add(a: int, b: int) -> int:
    return a + b

```


### ✔️ Blocks use indentation


Because the raccoon really liked that part.


```python
if x > 3:
    print("big")
else:
    print("small")

```


### ✔️ Loops look like Python


But compile down to classic `for(;;)`.


```python
for i in range(0, 10):
    print(i)

```


---


## 🔧 Under the Hood


PyCoon’s pipeline:


1. **Tokenize** Python-like syntax
2. **Parse** into a simple AST
3. **Type-check** with C-style rules
4. **Lower** into a minimal IR
5. **Emit**:


   - C code
   - or LLVM IR


No garbage collector.

No dynamic typing.

No magic.

Just raccoon-powered C semantics.


---


## 🦝 Mascot


**The Coon**


- Wears a cape
- Writes C in the shadows
- Steals Python syntax during the night
- Loves garbage cans, hates garbage collectors


Optional ASCII mascot:


```text
  (\_/)   <- raccoon
 ( •_•)  "pythonic enough"
 / >🦝>   cape mode activated

```


---


## 📦 Example Program


```python
def fib(n: int) -> int:
    if n < 2:
        return n
    return fib(n - 1) + fib(n - 2)


def main():
    print(fib(10))

```


Generated C skeleton:


```c
int fib(int n) {
    if (n < 2) return n;
    return fib(n-1) + fib(n-2);
}

int main() {
    printf("%d\n", fib(10));
}

```


---


## 🛣️ Roadmap


- Basic parser & AST
- C code generator
- LLVM IR backend
- Simple type system
- Modules
- `class` syntax that compiles to C structs
- Raccoon-mode optimizations
- Official PyCoon Cape (merch 🤓)


---


## 📝 License


You may choose any license you want. Default suggestion:


```text
MIT License

Do whatever you want, but don't blame the raccoon.

```


---


## 🎉 Final Note


PyCoon is not meant to be serious —

but it *is* meant to be **fun**, hackable, understandable, and surprisingly powerful.


## How to run the tokenizer

```
cd src
make
./onion
```
and input something to test it

## Run Example Tests
```
cd src
./ci
```
## Coding Guide
[Avoid memory leak ](doc/CODING_GUIDE.md)



### Language Features

| Language Feature      | Code Example |
|-----------------------|--------------|
| Variable Declaration  | int x;       |
| Addition              | x + y        |
| Subtraction           | x - y        |
| Multiply              | x * y        |
| Divide                | x / y        |
| Modulus               | x % y        |
| Less Than             | x < y        |
| Less Than Equal       | x <= y       |
| More Than             | x > y        |
| More Than Equal       | x >=y        |
| Not Equal             | x !=  y      |
| Assignment            | x = 5; x = y;|
| Logical And           | x>1 and y<2  |
| Logical Or            | x>1 or y<2   |
| While Loop            | while(condition) |
| Break loop control    | break        |
| Continue loop control | continue     |
| If else loop          | if(condition){} else{} |
| If elif else loop     | if(condition){} elif(cond2) elif(cond3) ... else{} |
| Write statements      | print(x);     |
| Read Statements       | read(x);      |
| Array Init            | Arr[fixed size y]; Arr[fixed size y] = one_init_value;Arr[optional_fixed size n] = {val1,val2,...,valn}; |
| Comments              | # Comments or /* comments */ |
| function              | fun fun_name(x,y,z,...){return t}|





### Table of Symbols

|Symbol                | Token Name   |
|----------------------|--------------|
|fun                  | Func         |
|return                | Return       |
|int                   | Int          |
|print                 | Print        |
|read                  | Read         |
|while                 | While        |
|if                    | If           |
|else                  | Else         |
|break                 | Break        |
|continue              | Continue     |
|(                     | LeftParen    |
|)                     | RightParen   |
|{                     | LeftCurly    |
|}                     | RightCurly   |
|[                     | LeftBracket  |
|]                     | RightBracket |
|,                     | Comma        |
|;                     | Semicolon    |
|+                     | Plus         |
|-                     | Subtract     |
|*                     | Multiply     |
|/                     | Divide       |
|%                     | Modulus      |
|=                     | Assign       |
|<                     | Less         |
|<=                    | LessEqual    |
|>                     | Greater      |
|>=                    | GreaterEqual |
|==                    | Equality     |
|!=                    | NotEqual     |
|variable_name         | Ident        |
|10311517              | IntergerNum  |
|0x10                  | BinaryNum    |

### Comments

Comments can be single line comments starting with `#`. For example:

```
int x; #This is a variable declaration.
```
Comments can also be block comments starting with `/*` and end with `*/`. For example:
```
/*This is a
variable
declaration.*/
int x; 
```
