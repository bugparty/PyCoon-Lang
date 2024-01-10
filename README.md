# Orion Programming Language
Author: [Bowen Han](https://github.com/bugparty), [Yuze Fu](https://github.com/fuyuze123), [Kevin Qu](https://github.com/KevinDevs), [Haosheng Long](https://github.com/hlonglhs).

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
| Logical And           | x>1 and y<2  |
| Logical Or            | x>1 or y<2   |
| While Loop            | while(condition) |
| Break loop control    | break        |
| Continue loop control | continue     |
| If else loop          | if(condition){} else{} |
| Write statements      | print(x);     |
| Read Statements       | read(x);      |
| Array Init            | Arr[fixed size y]; Arr[fixed size y] = (x); |
| Comments              | //Comments or /* comments */ |
| function              | fun(x,y,z,...){return t}|





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
