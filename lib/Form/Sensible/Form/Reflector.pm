package Form::Sensible::Form::Reflector;
use Moose;
use namespace::autoclean;
extends 'Form::Sensible', 'Form::Sensible::Form';
use Carp;
use Data::Dumper;
our $VERSION = '0.01';

has 'name' => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
    default  => sub { croak "Form name required" }
);

has 'options' => (
    is      => 'rw',
    isa     => 'HashRef',
    default => sub { {} }
);
has 'reflector' => (
    is       => 'rw',
	isa      => 'Form::Sensible::Form::Reflector',
	required => 1,
);

sub get_all_fields {
    my ($self, @types)  = shift;
    my @definitions;
    my @fields;
    my $translated;

    for (@types) {
        push @definitions,
          { name => $_, %{ $self->reflector->get_field_defaults_for($_) } };

    }

    for my $i ( 0 .. $#definitions ) {
        push @fields,
          {
            name        => $definitions[$i]->{'name'},
            field_class => $definitions[$i]->{'type'},
            size        => $definitions[$i]->{'size'},
          };
    }

    push @{$translated}, { name => $self->name, fields => \@fields };
    return $translated;
}


sub create_form {
    my ( $self, $opts ) = @_;
    my $reflector_class =
      "Form::Sensible::Form::Reflector::" . $opts->{'reflector'};
    Class::MOP::load_class($reflector_class) or die "didn't load reflector class: $!";
    my $reflector = $reflector_class->new;

    $self->reflector($reflector);
    $reflector->name( $opts->{'name'} );
    $reflector->options( $opts->{'options'} );

    my $formhash = $self->get_all_fields($reflector->get_all_fields);
    warn "Form shit: " . Dumper $opts->{'options'};
    my $form = Form::Sensible->create_form($formhash);
    return $form;
}
__PACKAGE__->meta->make_immutable;
1;
