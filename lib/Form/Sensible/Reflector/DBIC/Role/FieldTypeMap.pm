package Form::Sensible::Reflector::DBIC::Role::FieldTypeMap;
use Moose::Role;
use namespace::autoclean;

=head1 NAME

Form::Sensible::Reflector::DBIC::Role::FieldTypeMap - Map generic SQL data types to L<Form::Sensible> field types.

=cut

=head1 $self->field_type_map

Define a hashref of field->types.

Current incarnation is as follows:

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


=cut

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


=head1 AUTHOR

Devin Austin  L<mailto:devin.austin@ionzero.com>

Andre Walker  L<http://andrewalker.net>

=cut

1;
