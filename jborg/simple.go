package main

import (
	"fmt"
)

type Foo struct {
	Val1 int
	Val2 int
}

func printFoo(f Foo) {
	fmt.Printf("Foo: {%d, %d}\n", f.Val1, f.Val2)
}

func main() {
	var foo Foo = Foo{1, 2}

	printFoo(foo);
}
