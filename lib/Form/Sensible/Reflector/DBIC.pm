package Form::Sensible::Reflector::DBIC;
use Moose;
use namespace::autoclean;
extends 'Form::Sensible::Reflector';
our $VERSION = "0.0342";

# ABSTRACT: A Form::Sensible::Form::Reflector subclass to reflect off of DBIC schema classes

=head2 $self->get_types

this is an internal and private method used solely for organizing the hashmap 
of datatypes to Form::Sensible types.  Use something like this to organize your
own reflector subclass datatypes.

=cut

sub get_types {
    my $self = shift;
    return {
        varchar    => 'Text',
        text       => 'LongText',
        mediumtext => 'LongText',
        blob       => 'FileSelector',
        datetime   => 'Text',
        timestamp  => 'Text',
        enum       => 'Select',
        smallint   => 'Number',
        int        => 'Number',
        integer    => 'Number',
        mediumint  => 'Number',
        tinyint    => 'Number',
        bigint     => 'Number',
        bool       => 'Toggle',
        decimal    => 'Number'
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
    my ( $self, $form, $resultset ) = @_;
    return $resultset->result_source->columns;
}

=head1 $self->get_field_definition()
=cut

sub get_field_definition {
    my ( $self, $form, $resultset, $name ) = @_;
    ## TODO: Follow relationships

    ## check to see if it's a primary key
    my @pks   = $resultset->result_source->primary_columns;
    my $field = $resultset->result_source->column_info($name);
    if ( scalar( grep /$name/, @pks ) ) {
        return {
            name         => $name,
            field_class  => $self->get_field_type_for( $field->{'data_type'} ),
            render_hints => { field_type => "hidden" }
        };
    }

    return {
        name          => $name,
        field_class   => $self->get_field_type_for( $field->{'data_type'} ),
        render_hints  => $field->{'render_hints'} || {},
        default_value => $field->{'default_form_value'}
          if exists $field->{'default_form_value'},
    };
}

__PACKAGE__->meta->make_immutable;
1;

=head1 NAME 
 
Form::Sensible::Form::Reflector::DBIC - A reflector class based on Form::Sensible and Form::Sensible::Form::Reflector

=cut

=head1 SYNOPSIS

	my $schema = TestSchema->connect('dbi:SQLite::memory:');
	$schema->deploy;
	use Form::Sensible;
	use Form::Sensible::Reflector::DBIC;
	## name must reflect the table which we are reflecting

	my $dt = DateTime->now;

	my $reflector = Form::Sensible::Reflector::DBIC->new;
	my $form      = $reflector->reflect_from(
	    $schema->resultset("Test"),
	    {
	        form   => { name => 'test' }
	    }
	);
	my $submit_button = Form::Sensible::Field::Trigger->new( name => 'submit' );
	my $renderer = Form::Sensible->get_renderer('HTML');

	$form->add_field($submit_button);
	$form->set_values( { date => $dt } );
	my $output = $renderer->render($form)->complete;

=cut

