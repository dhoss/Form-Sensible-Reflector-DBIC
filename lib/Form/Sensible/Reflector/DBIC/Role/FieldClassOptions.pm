package Form::Sensible::Reflector::DBIC::Role::FieldClassOptions;
use Moose::Role;
use namespace::autoclean;

=head1 NAME

Form::Sensible::Reflector::DBIC::Role::FieldClassOptions - Sane defaults for field classes.

=cut


=head1 $self->field_class_options

Hashref of default field class options.

Current incarnation: 

    'Number' => {
        'validation' => {
          'integer_only' => 'integer_only',
          'upper_bound'  => 'upper_bound',
          'lower_bound'  => 'lower_bound',
          'step'         => 'step',
        },
      },
      'Toggle' => {
        'render_hints' => {
          'on_value'  => 'on_value',
          'on_label'  => 'on_label',
          'off_value' => 'off_value',
          'off_label' => 'off_label',
        },
      },
      'Text' => {
        'validation' => {
          'size'            => 'maximum_length',
          'minimum_length'  => 'minimum_length',
          'maximum_length'  => 'maximum_length',
          'should_truncate' => 'should_truncate',
        },
      },
      'LongText' => {
        'validation' => {
          'size'            => 'maximum_length',
          'minimum_length'  => 'minimum_length',
          'maximum_length'  => 'maximum_length',
          'should_truncate' => 'should_truncate',
        },
      },
      'FileSelector' => { 'validation' => { 'size' => 'maximum_size', }, },
      'Select' =>
        { 'validation' => { 'options_delegate' => 'options_delegate', }, },


=cut

has 'field_class_options' => (
  is         => 'rw',
  isa        => 'HashRef',
  required   => 1,
  lazy_build => 1,
);

sub _build_field_class_options {
    return {
      'Number' => {
        'validation' => {
          'integer_only' => 'integer_only',
          'upper_bound'  => 'upper_bound',
          'lower_bound'  => 'lower_bound',
          'step'         => 'step',
        },
      },
      'Toggle' => {
        'render_hints' => {
          'on_value'  => 'on_value',
          'on_label'  => 'on_label',
          'off_value' => 'off_value',
          'off_label' => 'off_label',
        },
      },
      'Text' => {
        'validation' => {
          'size'            => 'maximum_length',
          'minimum_length'  => 'minimum_length',
          'maximum_length'  => 'maximum_length',
          'should_truncate' => 'should_truncate',
        },
      },
      'LongText' => {
        'validation' => {
          'size'            => 'maximum_length',
          'minimum_length'  => 'minimum_length',
          'maximum_length'  => 'maximum_length',
          'should_truncate' => 'should_truncate',
        },
      },
      'FileSelector' => { 'validation' => { 'size' => 'maximum_size', }, },
      'Select' =>
        { 'validation' => { 'options_delegate' => 'options_delegate', }, },
    };
}

1;
