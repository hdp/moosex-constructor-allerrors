package MooseX::Constructor::AllErrors::Role::Object;

use Moose::Role;
use Moose::Util;
use MooseX::Constructor::AllErrors::Error;

my $new_error = sub { 
  my $class = shift;
  return "MooseX::Constructor::AllErrors::Error::$class"->new(@_);
};

around BUILDARGS => sub {
  my ($orig, $self, @args) = @_;

  my $args = $self->$orig(@args);

  my $error = $new_error->(Constructor => {
    caller => [ caller(3) ],
  });

  my $meta = Moose::Util::find_meta($self);
  for my $attr ($meta->compute_all_applicable_attributes) {
    next unless defined( my $init_arg = $attr->init_arg );

    if ($attr->is_required and 
      ! $attr->is_lazy and
      ! $attr->has_default and
      ! $attr->has_builder and
      ! exists $args->{$init_arg}) {
      $error->add_error($new_error->(Required => { attribute => $attr }));
      next;
    }

    next unless exists $args->{$init_arg} && $attr->has_type_constraint;

    unless ($attr->type_constraint->check($args->{$init_arg})) {
      $error->add_error($new_error->(TypeConstraint => {
        attribute => $attr,
        data      => $args->{$init_arg},
      }));
      next;
    }
  }

  if ($error->has_errors) {
    $meta->throw_error($error, params => $args);
  }

  return $args;
};

1;
