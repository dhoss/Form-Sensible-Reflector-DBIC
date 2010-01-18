package Form::Sensible::Form::Reflector;
use Moose;
use namespace::autoclean;
extends 'Form::Sensible', 'Form::Sensible::Form';
our $VERSION = '0.01';

# ABSTRACT: A simple reflector class for Form::Sensible

has 'options' => (
    is       => 'rw',
    isa      => 'HashRef',
    required => 1,
);

=head2 $self->create_form($opts)

override L<Form::Sensible>'s C<create_form> method so we can add in the info we want from DBIC

=cut

sub create_form {
    my ( $self, $opts ) = @_;
    my @names = $self->get_all_fields($opts);
    my @formhash;
    my @fields;
    for (@names) {
        push @fields,
          {
            name         => $_->{'name'},
            render_hints => $_->{'render_hints'} || {},
            field_class  => $self->get_field_types_for( $_->{'type'} )
          };
    }
    push @formhash, { name => $opts->{'name'}, fields => \@fields };
    my $form = Form::Sensible->create_form(@formhash);
    return $form;
}

__PACKAGE__->meta->make_immutable;
1;
