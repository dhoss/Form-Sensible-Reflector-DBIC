package Form::Sensible::Reflector;
use Moose;
use namespace::autoclean;
use Carp;
use Data::Dumper;
extends 'Form::Sensible', 'Form::Sensible::Form';
our $VERSION = '0.02';

# ABSTRACT: A simple reflector class for Form::Sensible

=head2 $self->create_form($opts)

override L<Form::Sensible>'s C<create_form> method so we can add in the info we want from DBIC

=cut

sub create_form {
    my ( $self, $opts ) = @_;


   	my $form;
	if ( ref $opts->{'form'} eq 'HASH') {
		$form = Form::Sensible::Form->new(%{$opts->{'form'}});
    } elsif ( ref $opts->{'form'} eq 'HASH' ) {
	    $form = $opts->{'form'};
    }
    my @columns = $self->get_fieldnames($form, $opts->{'handle'}); 
    my @definitions;

    for (@columns) {
	   warn "Processing: " . $_;
       $form->add_field($self->get_field_definition($form, $opts->{'handle'}, $_));
    }
    warn "Form in create_form: " . Dumper $form;
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

	sub get_field_types_for { ... }
	sub get_fieldnames { ... }
	sub get_field_definition { ... }

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
