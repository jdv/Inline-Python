#!/usr/bin/env perl6

use v6;
use Inline::Python;

say "1..12";

my $py = Inline::Python.new();
say $py.run('

def test():
    print "ok 1 - executing a parameterless function without return value";
    return;

def test_int_params(a, b):
    if a == 2 and b == 1:
        print "ok 2 - int params";
    else:
        print "not ok 2 - int params";
    return;

def test_str_params(a, b):
    if a == "Hello" and b == "Python":
        print "ok 3 - str params";
    else:
        print "not ok 3 - str params";
    return;

def test_int_retval():
    return 1;

def test_int_retvals():
    return 3, 1, 2;

def test_str_retval():
    return u"Hello Perl 6!";

def test_mixed_retvals():
    return (u"Hello", u"Perl", 6);

def test_none(undef):
    return undef is None;

import types
def test_hash(h):
    return (
        isinstance(h, types.DictType)
        and len(h.keys()) == 2
        and "a" in h
        and "b" in h
        and h["a"] == 2
        and isinstance(h["b"], types.DictType)
        and isinstance(h["b"]["c"], types.ArrayType)
        and len(h["b"]["c"]) == 2
        and h["b"]["c"][0] == 4
        and h["b"]["c"][1] == 3
    )

def test_foo(foo):
    return foo.test();

class Foo:
    def __init__(self, val):
        self.val = val

    def test(self):
        return self.val

    def sum(a, b):
        return a + b
');

$py.call('__main__', 'test');
$py.call('__main__', 'test_int_params', 2, 1);
$py.call('__main__', 'test_str_params', 'Hello', 'Python');
if ($py.call('__main__', 'test_int_retval') == 1) {
    say "ok 4 - return one int";
}
else {
    say "not ok 4 - return one int";
}
my @retvals = $py.call('__main__', 'test_int_retvals');
if (@retvals == 3 and @retvals[0] == 3 and @retvals[1] == 1 and @retvals[2] == 2) {
    say "ok 5 - return three ints";
}
else {
    say "not ok 5 - return three ints";
    say "    got: {@retvals}";
    say "    expected: 3, 1, 2";
}
if ($py.call('__main__', 'test_str_retval') eq 'Hello Perl 6!') {
    say "ok 6 - return one string";
}
else {
    say "not ok 6 - return one string";
}
@retvals = $py.call('__main__', 'test_mixed_retvals');
if (@retvals == 3 and @retvals[0] eq 'Hello' and @retvals[1] eq 'Perl' and @retvals[2] == 6) {
    say "ok 7 - return mixed values";
}
else {
    say "not ok 7 - return mixed values";
    say "    got: {@retvals}";
    say "    expected: 'Hello', 'Perl', 6";
}

if ($py.call('__main__', 'Foo::new', 'Foo', 1).test() == 1) {
    say "ok 8 - Perl 5 method call";
}
else {
    say "not ok 8 - Perl 5 method call";
}

if ($py.call('__main__', 'Foo::new', 'Foo', 1).sum(3, 1) == 4) {
    say "ok 9 - Perl 5 method call with parameters";
}
else {
    say "not ok 9 - Perl 5 method call with parameters";
}

if ($py.call('__main__', 'test_none', Any) == 1) {
    say "ok 10 - Any converted to undef";
}
else {
    say "not ok 10 - Any converted to undef";
}

if ($py.call('__main__', 'test_hash', {a => 2, b => {c => [4, 3]}}) == 1) {
    say "ok 11 - Passing hashes to Perl 5";
}
else {
    say "not ok 11 - Passing hashes to Perl 5";
}

if ($py.call('__main__', 'test_foo', $py.call('__main__', 'Foo', 6)) == 6) {
    say "ok 12 - Passing Perl 5 objects back from Perl 6";
}
else {
    say "not ok 12 - Passing Perl 5 objects back from Perl 6";
}

# vim: ft=perl6
