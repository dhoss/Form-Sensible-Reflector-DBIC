package Form::Sensible::Form::Reflector::DBIC;
use Moose;
use namespace::autoclean;
extends 'Form::Sensible::Form::Reflector';
our $VERSION = "0.01";

# ABSTRACT: A Form::Sensible::Form::Reflector subclass to reflect off of DBIC schema classes

=head2 $self->get_all_fields($opts)

this grabs all the fields by name from your data source. then it loops through 
and adds the fields definitions/constraints to the appropriate field, and returns
an AoH containing this data.

=cut

sub get_all_fields {
    my ( $self, $opts ) = @_;
    my $schema  = $opts->{'options'}->{'schema'};
    my @columns = $schema->source( ucfirst $opts->{'name'} )->columns;
    my @definitions;
    for (@columns) {
        push @definitions,
          {
            name => $_,
            type => $schema->source( ucfirst $opts->{'name'} )->column_info($_)
              ->{'data_type'},
            render_hints =>
              $schema->source( ucfirst $opts->{'name'} )->column_info($_)
              ->{'render_hints'},
          };
    }
    return @definitions;
}


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
        bigint   => 'Number',
        bool     => 'Toggle',
    };
}

=head2 $self->get_field_types_for($datatype)

This gets field definitions for a given datatype and returns them in hashref form.

=cut

sub get_field_types_for {
    my ( $self, $sql_type ) = @_;
    ## big ass hash for mapping sql->form types
    ## use respective DBMS role, call ->get_types
    my $types = $self->get_types;
    return $types->{$sql_type};
}

__PACKAGE__->meta->make_immutable;
1;
