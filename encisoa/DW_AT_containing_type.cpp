struct S {
  void fm() {}
};

class C {
  public:
    void fm() {}
};

void foo() {
  S s;
  s.fm();

  C c;
  c.fm();
}
