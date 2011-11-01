package Form::Sensible::Reflector::DBIC::Role::FieldTypeMap;
use Moose::Role;
use namespace::autoclean;

has field_type_map => (
  is         => 'rw',
  isa        => 'HashRef',
  required   => 1,
  lazy_build => 1,
);

sub _build_field_type_map {
    return {
      varchar  => { defaults => { field_class => 'Text', }, },
      text     => { defaults => { field_class => 'LongText', }, },
      blob     => { defaults => { field_class => 'FileSelector' }, },
      datetime => { defaults => { field_class => 'Text', }, },
      enum     => { defaults => { field_class => 'Select', }, },
      int      => {
        defaults => {
          field_class  => 'Number',
          integer_only => 1,
        },
      },
      integer => {
        defaults => {
          field_class  => 'Number',
          integer_only => 1,
        },
      },
      bigint => {
        defaults => {
          field_class  => 'Number',
          integer_only => 1,
        },
      },
      bool => {
        defaults => {
          field_class => 'Toggle',
          on_value    => 1,
          on_label    => 'yes',
          off_value   => 0,
          off_label   => 'no'
        },
      },
      decimal => {
        defaults => {
          field_class  => 'Number',
          integer_only => 0,
        },
      },
    };
};

1;
