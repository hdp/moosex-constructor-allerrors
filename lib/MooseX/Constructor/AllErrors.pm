package MooseX::Constructor::AllErrors;

use strict;
use warnings;

use Moose ();
use Moose::Exporter;
use Moose::Util::MetaRole;
use MooseX::Constructor::AllErrors::Meta::Class;
use MooseX::Constructor::AllErrors::Meta::Attribute;

Moose::Exporter->setup_import_methods(also => 'Moose');

sub init_meta {
  shift;
  my %options = @_;

  Moose->init_meta(%options);

  Moose::Util::MetaRole::apply_metaclass_roles(
    for_class => $options{for_class},
    metaclass_roles => [
      'MooseX::Constructor::AllErrors::Meta::Class',
    ],
    attribute_metaclass_roles => [
      'MooseX::Constructor::AllErrors::Meta::Attribute',
    ],
  );
}

1;
