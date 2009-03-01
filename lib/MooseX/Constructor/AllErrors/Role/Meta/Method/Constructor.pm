package MooseX::Constructor::AllErrors::Role::Meta::Method::Constructor;

use Moose::Role;

around _generate_BUILDALL => sub {
  my ($orig, $self, @args) = @_;
  my $source = $self->$orig(@args);

  $source .= ";\n" if $source;

  my @attrs = grep { defined $_->init_arg } @{$self->attributes};
  my @required = map { "'" . $_->init_arg . "' => 1," }
    grep {
      $_->is_required 
      && ! $_->has_default
      && ! $_->has_builder
    } @attrs
  ;
    
  my @tc = map {
    q{'} . $_->init_arg . q{' => '} . $_->type_constraint->name . q{',}
  } grep {  $_->has_type_constraint } @attrs;


  $source .= <<"EOF";
my \$all_errors = MooseX::Constructor::AllErrors::Error::Constructor->new(
  caller => [caller(1)],
);
my \%required_attrs = (@required);
for my \$required_attr (keys \%required_attrs) {
  next if exists \$params->{\$required_attr};
  \$all_errors->add_error(
    MooseX::Constructor::AllErrors::Error::Required->new(
      attribute =>
        Moose::Util::find_meta(\$instance)->get_attribute(\$required_attr)
    )
  );
}
my \%tc_attrs = (@tc);
for my \$tc_attr (keys \%tc_attrs) {
  next unless exists \$params->{\$tc_attr};
  next if find_type_constraint(\$tc_attrs{\$tc_attr})->check(
    \$params->{\$tc_attr}
  );
  \$all_errors->add_error(
    MooseX::Constructor::AllErrors::Error::TypeConstraint->new(
      attribute =>
        Moose::Util::find_meta(\$instance)->get_attribute(\$tc_attr),
      data => \$params->{\$tc_attr},
    )
  );
}
if (\$all_errors->has_errors) {
  Moose::Util::find_meta(\$instance)->throw_error(
    \$all_errors,
    params => \$params,
  );
}
EOF

  return $source;
};

no Moose::Role;

1;
