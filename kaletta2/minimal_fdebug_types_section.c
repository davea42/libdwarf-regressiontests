struct A {
    int a1;
    int b1;
    int c1;
    int d1;
    int f1;
    int i1;
};

struct B {
    struct A a2;
    struct A b2;
    struct A c2;
    struct A d2;
    struct A f2;
    struct A g2;
};

struct C {
    struct B a3;
    struct B b3;
    struct B c3;
    struct B d3;
    struct B f3;
    struct B g3;
};

struct D {
    struct C a4;
    struct C b4;
    struct C c4;
    struct C d4;
    struct C f4;
    struct C g4;
};

struct D a5;
struct D b5;
struct D c5;
struct D d5;
struct D f5;
struct D g5; 
