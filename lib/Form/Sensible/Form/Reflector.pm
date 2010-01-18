package Form::Sensible::Form::Reflector;
use Moose;
use namespace::autoclean;
extends 'Form::Sensible', 'Form::Sensible::Form';
our $VERSION = '0.01';

has 'options' => (
    is         => 'rw',
    isa        => 'HashRef',
    required   => 1,
);

sub create_form {
    my ( $self, $opts ) = @_;
    my @names = $self->get_all_fields($opts);
	my @formhash;
	my @fields;
	for ( @names ) {
	    push @fields,{ name => $_->{'name'}, render_hints => $_->{'render_hints'} || {}, field_class => $self->get_field_types_for($_->{'type'})}; 
    }
    push @formhash, { name => $opts->{'name'}, fields => \@fields };
    my $form = Form::Sensible->create_form(@formhash);
    return $form;
}

__PACKAGE__->meta->make_immutable;
1;
