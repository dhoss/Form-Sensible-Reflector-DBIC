package Form::Sensible::Reflector::DBIC;
use Moose;
use namespace::autoclean;
extends 'Form::Sensible::Reflector';
our $VERSION = "0.0343";
$VERSION = eval $VERSION;

use Data::Dumper;

# ABSTRACT: A Form::Sensible::Form::Reflector subclass to reflect off of DBIC schema classes

=head2 $self->get_types

this is an internal and private method used solely for organizing the hashmap 
of datatypes to Form::Sensible types.  Use something like this to organize your
own reflector subclass datatypes.

=cut

has 'field_type_map' => (
    is       => 'rw',
    isa      => 'HashRef',
    required => 1,
    lazy     => 1,
    default  => sub {
        return {
            varchar => {
                field_class     => 'Text',
                parameter_names => [qw/minimum_length maximum_length should_truncate/],
            },
            text => {
                field_class     => 'LongText',
                parameter_names => [qw/minimum_length maximum_length should_truncate/],
            },
            blob     => { field_class => 'FileSelector', },
            datetime => { field_class => 'Text', },
            enum     => { field_class => 'Select', },
            int      => {
                field_class     => 'Number',
                parameter_names => [qw/integer_only upper_bound lower_bound step/],
                force           => { integer_only => 1 }
            },
            integer => {
                field_class     => 'Number',
                parameter_names => [qw/integer_only upper_bound lower_bound step/],
                force           => { integer_only => 1 }
            },
            bigint => {
                field_class     => 'Number',
                parameter_names => [qw/integer_only upper_bound lower_bound step/],
                force           => { integer_only => 1 }
            },
            bool => {
                field_class     => 'Toggle',
                parameter_names => [qw/on_value off_value on_label off_label/],
            },
            decimal => {
                field_class     => 'Number',
                parameter_names => [qw/integer_only upper_bound lower_bound step/],
                force           => { integer_only => 0 }
            }
        };
    },
);

=head2 $self->get_field_types_for($datatype)

This gets field definitions for a given datatype and returns them in hashref form.

=cut

sub get_field_type_for {
    my ( $self, $sql_type ) = @_;
    ## big ass hash for mapping sql->form types
    ## use respective DBMS role, call ->get_types
    return $self->field_type_map->{$sql_type};
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
    my @pks        = $resultset->result_source->primary_columns;
    my $columninfo = $resultset->result_source->column_info($name);

    my $params = $self->get_field_type_for( $columninfo->{'data_type'} );

    my $definition = {
        name        => $name,
        field_class => $params->{'field_class'}
    };

    foreach my $key ( @{ $params->{'parameter_names'} }, qw/render_hints/ ) {
        if ( exists( $columninfo->{'validation'}{$key} ) ) {
            $definition->{$key} = $columninfo->{'validation'}{$key};
        }
    }

    foreach my $key (qw/regex required code/) {
        if ( !exists( $definition->{'validation'} ) ) {
            $definition->{'validation'} = {};
        }
        if ( exists( $columninfo->{validation}{$key} ) ) {
            $definition->{'validation'}{$key} = $columninfo->{'validation'}{$key};
        }
    }

    foreach my $key ( keys %{ $params->{'force'} } ) {
        $definition->{$key} = $params->{'force'}{$key};
    }

    $definition->{render_hints} = $columninfo->{'render_hints'} || {};

    if ( scalar( grep /$name/, @pks ) ) {

        $definition->{'render_hints'} = { 'field_type' => 'hidden' };
    }

    if ( $columninfo->{'data_type'} eq 'enum' ) {
        if ( exists( $columninfo->{'render_hints'}{'options'} ) ) {
            push @{ $definition->{options} }, @{ $columninfo->{'render_hints'}{'options'} };
        }
    }

    if ( $columninfo->{'data_type'} eq 'bool' ) {
        if ( exists( $columninfo->{'render_hints'} ) ) {
            $definition->{on_value}  = $columninfo->{'render_hints'}{'on_value'};
            $definition->{off_value} = $columninfo->{'render_hints'}{'off_value'};
            $definition->{on_label}  = $columninfo->{'render_hints'}{'on_label'};
            $definition->{off_label} = $columninfo->{'render_hints'}{'off_label'};
        }
    }

## default value handling?  do we bother here?
    return $definition;
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

