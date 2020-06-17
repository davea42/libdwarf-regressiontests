// Build with:
// clang++ -g -gsplit-dwarf -gz -fdebug-default-version=5 -std=gnu++17 -c filecheck.cpp -o filecheck.o

namespace a {
inline namespace b {
template <class c> struct e { typedef c h; };
template <class c> struct e<c &> { typedef c h; };
template <class c> typename e<c>::h d(c &&);
template <class c> c aa();
template <class> class j;
template <class c, class = j<c>> class m;
template <class> struct D;
template <class c> struct D<c *> { typedef c f; };
template <class g> class r {
public:
  typename D<g>::f operator*();
  void operator++();
};
template <class i, class p> bool operator!=(i, p);
template <class c> struct s { typedef c *h; };
template <class c> struct t { typedef typename s<c>::h h; };
template <class c> class j {
public:
  typedef c *k;
};
template <class c> class l {
public:
  ~l();
  typename t<c>::h operator->();
};
} // namespace b
} // namespace a
class I {
public:
  static int ab;
  I ac();
};
namespace a {
namespace b {
template <class, class n> class m {
public:
  typedef r<typename n ::k> ad;
  ad begin();
  ad end();
};
} // namespace b
} // namespace a
class ae {
public:
  template <typename> bool af();
};
class J {
  template <typename... ag> friend J ah(J, ag &&...);
  J &&ai;
  void operator=(J);
  a::l<ae> aj();
};
class ak {
  template <typename... ag> friend J ah(J, ag &&...);
  a::m<a::l<ae>> al;
};
template <typename am>
class an : public an<decltype(&a::e<am>::h::operator())> {};
template <typename ao> class an<void (&)(ao)> {
public:
  template <typename am> static J ap(am, a::l<ae>);
};
template <typename aq, typename ar, typename ao>
class an<ar (aq::*)(ao) const> : public an<ar (&)(ao)> {};
template <typename am> void as(a::l<ae> at, am) {
  {
    a::l au = d(at);
    an<am>::ap(0, au);
  }
}
template <typename... ag> J ah(J av, ag &&...) {
  a::l at = av.aj();
  if (at->af<ak>()) {
    ak aw;
    for (auto ax : aw.al)
      as(ax, a::aa<ag>()...);
  }
}
template <typename... ag> void q(J av, ag...) { ah(a::d(av), a::aa<ag>()...); }
inline void ay(J az) {
  q(a::d(az), [](ae) {});
}
struct u {
  a::m<int> ba;
  bool bb() const;
};
namespace a {
class v {
protected:
  ~v();
};
class w : v {};
} // namespace a
void bc() { ay; }
I o;
bool u::bb() const {
  a::w bd;
  for (auto be = ba;;) {
    I bs = o.ac();
    return I::ab;
  }
}
