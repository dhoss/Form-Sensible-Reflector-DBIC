package Form::Sensible::Reflector::DBIC;
use Moose;
use namespace::autoclean;
extends 'Form::Sensible::Reflector';
our $VERSION = "0.0344";
$VERSION = eval $VERSION;

use Data::Dumper;

# ABSTRACT: A Form::Sensible::Reflector subclass to reflect off of DBIC schema classes

has 'field_type_map' => (
    is       => 'rw',
    isa      => 'HashRef',
    required => 1,
    lazy     => 1,
    default  => sub {
        return {
            varchar => {
                defaults      => {
                                    field_class     => 'Text',
                                 },
            },
            text => {
                defaults        => {
                                      field_class     => 'LongText',
                                   },
            },
            blob     => { 
                            defaults => { field_class => 'FileSelector' },
                        },
            datetime => { defaults => { field_class => 'Text', }, },
            enum     => { defaults => { field_class => 'Select', }, },
            int      => {
                defaults        => {
                                        field_class     => 'Number',
                                        integer_only => 1,
                                   },
            },
            integer => {
                defaults        => {
                                        field_class     => 'Number',
                                        integer_only => 1,
                                   },    
            },
            bigint => {
                defaults        => {
                                        field_class     => 'Number',
                                        integer_only => 1,
                                   },    
            },
            bool => {
                defaults => { 
                            field_class => 'Toggle',
                            on_value    => 1,
                            on_label    => 'yes',
                            off_value   => 0,
                            off_label   => 'no' 
                        },
            },
            decimal => {
                defaults => {
                                field_class     => 'Number',
                                integer_only => 0,
                            },
            },            
        };
    },
);

has 'field_class_options' => (
    is       => 'rw',
    isa      => 'HashRef',
    required => 1,
    lazy     => 1,
    default  => sub {
        return {
                    'Number' => {
                        'validation' => {
                            'integer_only' => 'integer_only',
                            'upper_bound'  => 'upper_bound',
                            'lower_bound'  => 'lower_bound',
                            'step'         => 'step',
                        },
                    },
                    'Toggle' => {
                        'render_hints' => {
                            'on_value'  => 'on_value',
                            'on_label'  => 'on_label',
                            'off_value' => 'off_value',
                            'off_label' => 'off_label',
                        },
                    },
                    'Text' => {
                        'validation' => {
                            'size' => 'maximum_length',
                            'minimum_length' => 'minimum_length',
                            'maximum_length' => 'maximum_length',
                            'should_truncate' => 'should_truncate',
                        },
                    },
                    'LongText' => {
                        'validation' => {
                            'size' => 'maximum_length',
                            'minimum_length' => 'minimum_length',
                            'maximum_length' => 'maximum_length',
                            'should_truncate' => 'should_truncate',
                        },
                    },
                    'FileSelector' => {
                        'validation' => {
                            'size' => 'maximum_size',
                        },
                    },
                    'Select' => {
                        'validation' => {
                            'options_delegate' => 'options_delegate',
                        },
                    },
        };
    }
);

=head2 $self->get_field_types_for($datatype)

This gets field definitions for a given datatype and returns them in hashref form.

=cut

sub get_base_definition {
    my ( $self, $name, $columninfo ) = @_;
    ## big ass hash for mapping sql->form types
    ## use respective DBMS role, call ->get_types
    my $definition = {
        'name' => $name,
    };
    
    my $type = $columninfo->{'data_type'};
    if (!exists($self->field_type_map->{$type})) {
        $type = 'varchar';
    }
    my $field_type_map = $self->field_type_map->{$type};

    # set up any defaults we might have.  These are values, no mapping here.
    if (exists($field_type_map->{'defaults'})) {
        foreach my $parameter (keys %{$field_type_map->{'defaults'}}) {
            $definition->{$parameter} = $field_type_map->{'defaults'}{$parameter};
        }
    }
    
    ## always allow field_class to be overridden:
    ##$definition->{'field_class'} = $columninfo->{'validation'}{'field_class'};
    
    # this loops over the attribute map and brings over any attributes that can be directly
    # applied.  This is useful for things like 'size' where the columninfo itself will tell you
    # maximum length, etc.  It's also used to find any override parameters provided by the user in the validation
    # or render_hints keys in the column info.
    print STDERR "FOO " . $definition->{'field_class'} . "\n";
    my $attribute_map = $self->field_class_options->{$definition->{'field_class'}} || {};
    if (exists($field_type_map->{'attribute_map'})) { 
        foreach my $attribute ( keys %{$field_type_map->{'attribute_map'}} ) {
            $attribute_map->{$attribute} = $field_type_map->{'attribute_map'}{$attribute};
        }
    }
    
    foreach my $attribute ( keys %{$attribute_map} ) {
        my $mappedkey = $attribute_map->{$attribute};
        
        if (ref($mappedkey) eq 'HASH') {
            my $section = $attribute;
            foreach my $attr (keys %{$mappedkey}) {
                if (exists($columninfo->{$section}{$attr})) {
                    $definition->{$mappedkey} = $columninfo->{$section}{$attr};
                }
            }
        } else {
            if (exists($columninfo->{$attribute})) {
                $definition->{$mappedkey} = $columninfo->{$attribute};
            }
        }
    }
    
    ## now we can add some detailed processing of types here - for example - select processing:

    ## we already allow setting of 'options_delegate' directly, but if we just want to specify the allowed options
    ## we can do it by setting the values in $columninfo->{'validation'}{'options'}
    if ( $definition->{'field_class'} eq 'Select' ) {
        if ( exists( $columninfo->{'validation'}{'options'} ) ) {
            my $options = [];
            push @{ $options}, @{ $columninfo->{'validation'}{'options'} };
            $definition->{'options_delegate'} = sub {
                return $options;
            };
        }
    }
    
    return $definition; 
}

=head1 $self->get_fieldnames()
=cut

sub get_fieldnames {
    my ( $self, $form, $handle ) = @_;
    return $self->result_source_for($handle)->columns;
}

=head1 $self->get_field_definition()
=cut

sub get_field_definition {
    my ( $self, $form, $handle, $name ) = @_;
    ## TODO: Follow relationships

    ## check to see if it's a primary key
    my $result_source = $self->result_source_for($handle);
    my @pks        = $result_source->primary_columns;
    my $columninfo = $result_source->column_info($name);

    ## this does the basics of the field definitions including field mapping.  Then we 
    ## do some general stuff that applies to ALL field types...
    
    my $definition = $self->get_base_definition( $name, $columninfo );

    if ( !exists( $definition->{'validation'} ) ) {
        $definition->{'validation'} = {};
    }
    
    ## by default, we obey is_nullable to determine whether the field is required.
    if ($columninfo->{'is_nullable'}) {
        $definition->{'validation'}{required} = 0;
    } else {
        $definition->{'validation'}{required} = 1;
    }
    
    ## these require special handling, as they need to go into the validation subhash
    ## when found.
    foreach my $key (qw/regex required code/) {
        if ( exists( $columninfo->{'validation'}{$key} ) ) {
            $definition->{'validation'}{$key} = $columninfo->{'validation'}{$key};
        }
    }
    
    $definition->{render_hints} = $columninfo->{'render_hints'} || {};

    ## if we have an fs_definition, anything within it overrides what was set earlier.
    ## note that validation (and render_hints) are COMPLETELY OVERWRITTEN by the contents of fs_definition,
    ## no merging of subhashes is done.
    foreach my $key ( keys %{ $columninfo->{'fs_definition'} } ) {
        $definition->{$key} = $columninfo->{'fs_definition'}{$key};
    }

    ## if the column is part of the primary key, we default to hiding it on the form.  
    if ( scalar( grep /$name/, @pks ) ) {
        if (!exists($columninfo->{render_hints}{field_type})) {
            $definition->{'render_hints'} = { 'field_type' => 'hidden' };
        };
    }

 ## default value handling?  do we bother here?
    return $definition;
}

sub create_form_object {
    my ($self, $handle, $form_options) = @_;

    ## normally create_form_object will throw a fit if you give it no options because
    ## it needs at least a name.  If we get no options, we make up a name based on the resultsource we are looking at.
    
    my $options = {};
    if (ref($form_options) eq 'HASH') {
        %{$options} = map { $_ => $form_options->{$_} } keys %{$form_options};
    }
    if ( !(exists($options->{'name'}) && defined($options->{'name'})) ) {
        $options->{'name'} = $self->source_name || $self->result_class || $self->name || ref($self);
        if ($options->{'name'} =~ m/([^:]+)$/) {
            $options->{'name'} = $1;
        };
        $options->{'name'} =~ s/[^a-zA-Z0-9_]//g;
    }
    return Form::Sensible::Form->new($options);
}

sub result_source_for {
    my ($self, $handle) = @_;
    
    if ($handle->can('result_source')) {
        return $handle->result_source();
    } else {
        return $handle;
    }
}


__PACKAGE__->meta->make_immutable;
1;

=head1 NAME 
 
Form::Sensible::Reflector::DBIC - A reflector class based on Form::Sensible and Form::Sensible::Reflector

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

