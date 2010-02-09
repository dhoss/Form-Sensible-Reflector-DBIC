package Form::Sensible::Reflector::DBIC;
use Moose;
use namespace::autoclean;
extends 'Form::Sensible::Reflector';
our $VERSION = "0.017";

# ABSTRACT: A Form::Sensible::Form::Reflector subclass to reflect off of DBIC schema classes

=head2 $self->get_types

this is an internal and private method used solely for organizing the hashmap 
of datatypes to Form::Sensible types.  Use something like this to organize your
own reflector subclass datatypes.

=cut

sub get_types {
    my $self = shift;
    return {
        varchar  => 'Text',
        text     => 'LongText',
        blob     => 'FileSelector',
        datetime => 'Text',
        enum     => 'Select',
        int      => 'Number',
        integer  => 'Number',
        bigint   => 'Number',
        bool     => 'Toggle',
        decimal  => 'Number'
    };
}

=head2 $self->get_field_types_for($datatype)

This gets field definitions for a given datatype and returns them in hashref form.

=cut

sub get_field_type_for {
    my ( $self, $sql_type ) = @_;
    ## big ass hash for mapping sql->form types
    ## use respective DBMS role, call ->get_types
    my $types = $self->get_types;
    return $types->{$sql_type};
}

=head1 $self->get_fieldnames()
=cut

sub get_fieldnames {
    my ( $self, $form, $schema ) = @_;
    return $schema->source( ucfirst $form->name )->columns;
}

=head1 $self->get_field_definition()
=cut

sub get_field_definition {
    my ( $self, $form, $schema, $name ) = @_;
    my $field = $schema->source( ucfirst $form->name )->column_info($name);
    return {
        name         => $name,
        field_class  => $self->get_field_type_for( $field->{'data_type'} ),
        render_hints => $field->{'render_hints'} || {},
    };
}

__PACKAGE__->meta->make_immutable;
1;

=head1 NAME 
 
Form::Sensible::Form::Reflector::DBIC - A reflector class based on Form::Sensible and Form::Sensible::Form::Reflector

=cut

=head1 SYNOPSIS

cocks

=cut

