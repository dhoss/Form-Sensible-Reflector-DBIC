package Form::Sensible::Form::Reflector::DBIC;
use Moose;
use namespace::autoclean;
extends 'Form::Sensible::Form::Reflector';
our $VERSION = "0.01";

## otherwise return error string
sub get_all_fields {
    my ($self, $opts) = @_;
    my $schema  = $opts->{'options'}->{'schema'};
    my @columns = $schema->source( ucfirst $opts->{'name'} )->columns;
    my @definitions;
	for (@columns) {
        push @definitions, 
		{ 
			name => $_, 
			type =>  $schema->source( ucfirst $opts->{'name'} )->column_info($_)->{'data_type'}, 
		    render_hints => $schema->source( ucfirst $opts->{'name'} )->column_info($_)->{'render_hints'},
		};
	}
	return @definitions;
}
	
sub get_types {
    my $self = shift;
    return {
        varchar  =>  'Text' ,
        text     =>  'LongText' ,
        blob     =>  'FileSelector'  ,
        datetime =>  'Text'    ,
        enum     =>  'Select'  ,
        int      =>  'Number'  ,
        bigint   =>  'Number'  ,
        bool     =>  'Toggle'  ,
    };
}

sub get_field_types_for {
    my ( $self, $sql_type ) = @_;
    ## big ass hash for mapping sql->form types
    ## use respective DBMS role, call ->get_types
    my $types = $self->get_types;
	Dumper $types;
    return $types->{$sql_type};
}

__PACKAGE__->meta->make_immutable;
1;
