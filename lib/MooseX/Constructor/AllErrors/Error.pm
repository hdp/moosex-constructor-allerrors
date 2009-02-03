# vim: ts=4 sts=4 sw=4
package MooseX::Constructor::AllErrors::Error;

use Moose;

package MooseX::Constructor::AllErrors::Error::Constructor;

use Moose;
extends 'MooseX::Constructor::AllErrors::Error';

has errors => (
    is => 'ro',
    isa => 'ArrayRef',
    auto_deref => 1,
    lazy => 1,
    default => sub { [] },
);

has caller => (
    is => 'ro',
    isa => 'ArrayRef',
    required => 1,
);

sub has_errors {
    return scalar @{ $_[0]->errors };
}

sub add_error {
    my ($self, $error) = @_;
    push @{$self->errors}, $error;
}

sub message {
    my $self = shift;
    confess "$self->message called without any errors"
        unless $self->has_errors;
    return $self->errors->[0]->message;
}

sub stringify {
    my $self = shift;
    return '' unless $self->has_errors;
    return sprintf '%s at %s line %d',
        $self->message,
        $self->caller->[1], $self->caller->[2];
}

use overload (
    q{""} => 'stringify',
    fallback => 1,
);

package MooseX::Constructor::AllErrors::Error::Required;

use Moose;
extends 'MooseX::Constructor::AllErrors::Error';

has attribute => (
    is => 'ro',
    isa => 'Moose::Meta::Attribute',
    required => 1,
);

sub message {
    my $self = shift;
    return sprintf 'Attribute (%s) is required',
        $self->attribute->name;
}

package MooseX::Constructor::AllErrors::Error::TypeConstraint;

use Moose;
extends 'MooseX::Constructor::AllErrors::Error';

has attribute => (
    is => 'ro',
    isa => 'Moose::Meta::Attribute',
    required => 1,
);

has data => (
    is => 'ro',
    required => 1,
);

sub message {
    my $self = shift;
    return sprintf
        'Attribute (%s) does not pass the type constraint because: %s',
        $self->attribute->name,
        $self->attribute->type_constraint->get_message($self->data);
}

1;
