# vim: ts=4 sts=4 sw=4
package MooseX::Constructor::AllErrors::Meta::Class;

use Moose::Role;

use MooseX::Constructor::AllErrors::Error;
#use MooseX::Constructor::AllErrors::Error::Construct;

# XXX pretty much copied from Moose::Meta::Class
override construct_instance => sub {
    my $class = shift;
    my $params = @_ == 1 ? $_[0] : {@_};
    my $meta_instance = $class->get_meta_instance;

    my $instance = $params->{'__INSTANCE__'} || $meta_instance->create_instance();
    my $error = MooseX::Constructor::AllErrors::Error::Constructor->new;
    foreach my $attr ($class->compute_all_applicable_attributes()) {
        eval { 
            $attr->initialize_instance_slot($meta_instance, $instance, $params);
        };
        if (my $e = $@) {
            $error->add_error($@);
        }
    }
    $class->throw_error(
        $error,
        params   => $params,
    ) if $error->has_errors;
    return $instance;
};

1;
