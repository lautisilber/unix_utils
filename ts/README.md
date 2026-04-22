```ts``` is a program that allows you to pipe in any program and automatically add timestamps to the output. It can be especially useful when combined with ```tee```. Something like this

```bash
my_program_with_an_output_to_stdout | ts | tee log.txt
```
