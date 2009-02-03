# vim: ts=4 sts=4 sw=4
package MooseX::Constructor::AllErrors::Error;

package MooseX::Constructor::AllErrors::Error::Constructor;

use Moose;

has errors => (
    is => 'ro',
    isa => 'ArrayRef',
    auto_deref => 1,
    lazy => 1,
    default => sub { [] },
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

package MooseX::Constructor::AllErrors::Error::Required;

use Moose;

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

has attribute => (
    is => 'ro',
    isa => 'Moose::Meta::Attribute',
    required => 1,
);

has data => (
    is => 'ro',
    required => 1,
);

has extra => (
    is => 'ro',
    isa => 'HashRef',
    lazy => 1,
    default => sub { {} },
);

sub message {
    my $self = shift;
    return sprintf
        'Attribute (%s) does not pass the type constraint because: %s',
        $self->attribute->name,
        $self->attribute->type_constraint->get_message($self->data);
}

1;