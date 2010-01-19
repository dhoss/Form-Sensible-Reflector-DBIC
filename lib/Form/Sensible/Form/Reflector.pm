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

=head1 NAME

Form::Sensible::Form::Reflector - A base class for writing Form::Sensible reflectors.

=cut

=head1 SYNOPSIS

    package My::Reflector;
    use Moose;
    use namespace::autoclean;
    extends 'Form::Sensible::Form::Reflector';

	sub get_all_fields { ... }

	sub get_field_types_for { ... }

=cut

=head1 DESCRIPTION

This is a base class to write reflectors for things like, configuration files, or my favorite, a database
schema.

The idea is to give you something that creates a form from some other source that already defines form-like
properties, ie a database schema that already has all the properties and fields a form would need.

I personally hate dealing with forms that are longer than a search field or login form, so this really
fits into my style.

=cut

=head1 FEATURES

One of the first of its kind to actually reflect a L<DBIx::Class> schema with minimal setup and code.

=cut

=head1 EXAMPLES

See t/01test_reflector for a fairly comprehensive reflector setup.

=cut

=head1 AUTHOR

Devin Austin <dhoss@cpan.org>

=cut

=head1 SEE ALSO

L<Form::Sensible>
L<Form::Sensible> Wiki: L<http://wiki.catalyzed.org/cpan-modules/form-sensible>
L<Form::Sensible> Discussion: L<http://groups.google.com/group/formsensible>

=cut
