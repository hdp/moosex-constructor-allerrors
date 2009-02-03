use strict;
use warnings;
use Test::More tests => 11;

{
  package Foo;
  
  use MooseX::Constructor::AllErrors;

  has bar => (
    is => 'ro',
    required => 1,
  );

  has baz => (
    is => 'ro',
    isa => 'Int',
  );

  no MooseX::Constructor::AllErrors;
}

my $foo = eval { Foo->new(bar => 1) };
is($@, '');
isa_ok($foo, 'Foo');

eval { Foo->new(baz => "hello") };
my $e = $@;
my $t;
isa_ok($e, 'MooseX::Constructor::AllErrors::Error::Constructor');
isa_ok($t = $e->errors->[0], 'MooseX::Constructor::AllErrors::Error::Required');
is($t->attribute, Foo->meta->get_attribute('bar'));
is($t->message, 'Attribute (bar) is required');
isa_ok($t = $e->errors->[1], 'MooseX::Constructor::AllErrors::Error::TypeConstraint');
is($t->attribute, Foo->meta->get_attribute('baz'));
is($t->message,
  q{Attribute (baz) does not pass the type constraint because: Validation failed for 'Int' failed with value hello}
);

is(
  $e->message,
  $e->errors->[0]->message,
  "message is first error's message",
);

is("$e", "Attribute (bar) is required at " . __FILE__ . " line 27");
