package Form::Sensible::Reflector::DBIC::Role::FieldClassOptions;
use Moose::Role;
use namespace::autoclean;

has 'field_class_options' => (
  is       => 'rw',
  isa      => 'HashRef',
  required => 1,
  lazy     => 1,
  default  => sub {
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
);

1;
