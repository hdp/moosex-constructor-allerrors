# vim: ts=4 sts=4 sw=4
package MooseX::Constructor::AllErrors::Meta::Attribute;

use Moose::Role;

use MooseX::Constructor::AllErrors::Error;
#use MooseX::Constructor::AllErrors::Error::Required;
#use MooseX::Constructor::AllErrors::Error::TypeConstraint;

override initialize_instance_slot => sub {
    my ($self, $meta_instance, $instance, $params) = @_;
    my $init_arg = $self->init_arg;

    unless (defined $init_arg and exists $params->{$init_arg}) {
        if ($self->is_required and 
            ! $self->is_lazy and 
            ! $self->has_default and
            ! $self->has_builder) {
            die MooseX::Constructor::AllErrors::Error::Required->new(
                attribute => $self,
            );
        }
    }

    return super;
};

override verify_against_type_constraint => sub {
    my $self = shift;
    my $val  = shift;

    return 1 unless $self->has_type_constraint;

    my $type_constraint = $self->type_constraint;

    $type_constraint->check($val)
        || die MooseX::Constructor::AllErrors::Error::TypeConstraint->new(
            attribute => $self,
            data      => $val,
        );
};

1;
