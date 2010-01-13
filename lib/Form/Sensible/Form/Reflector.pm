package Form::Sensible::Form::Reflector;
use Moose;
use namespace::autoclean;
extends 'Form::Sensible', 'Form::Sensible::Form';
use Carp;
our $VERSION = '0.01';

has 'name' => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
    lazy     => 1,
    default  => sub { croak "Form name required" }
);

has 'reflector' => (
    is       => 'rw',
    isa      => "Form::Sensible::Form::Reflector",
    lazy     => 1,
    required => 1,
    default  => sub { croak "You must specify a reflector class" }
);

has 'options'   => (
    is       => 'rw', 
	isa      => 'HashRef',
	lazy     => 1,
	default  => sub { {} }
);

sub get_all_fields {
    my $self   = shift;
    my @types = $self->reflector->get_all_fields;
    my @definitions;
    my @fields;
    my $translated;

    for (@types) {
        push @definitions, { name => $_, %{ $self->get_field_defaults_for($_) } };

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

sub get_field_defaults_for {
    my ( $self, $field ) = shift;
    return $self->reflector->get_field_defaults_for($field)
	    or die "No reflector get_field_defaults_for class given!";
}

sub create_form {
	    my ( $self, $opts ) = @_;
		    my $reflector_class = "Form::Sensible::Form::Reflector::" . $opts->{'reflector'};
				Class::MOP::load_class($reflector_class);
					my $reflector = $reflector_class->new;
#	$reflector->reflector($reflector);
						$reflector->name($opts->{'name'});
						    $reflector->options($opts->{'options'});
								my $formhash = $reflector->get_all_fields;

								    my $form = Form::Sensible->create_form($formhash);
									    return $form;
}
__PACKAGE__->meta->make_immutable;
1;
