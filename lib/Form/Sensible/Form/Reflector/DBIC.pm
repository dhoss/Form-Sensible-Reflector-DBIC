package Form::Sensible::Form::Reflector::DBIC;
use Moose;
use namespace::autoclean;
extends 'Form::Sensible::Form::Reflector';
use Data::Dumper;
use DateTime;
use Carp;


## otherwise return error string
sub get_all_fields {
    my ($self, $opts) = @_;
    my $schema  = $opts->{'options'}->{'schema'};
    my @columns = $schema->source( ucfirst $opts->{'name'} )->columns;
    my @definitions;
	for (@columns) {
        push @definitions, { name => $_, type =>  $schema->source( ucfirst $opts->{'name'} )->column_info($_)->{'data_type'} };
	}
	return @definitions;
}
	
sub get_types {
    my $self = shift;
    return {
        varchar  => [ { type => 'Text' } ],
        text     => [ { type => 'LongText'} ],
        blob     => [ { type => 'FileSelector' } ],
        datetime => [ { type => 'Text'   } ],
        enum     => [ { type => 'Select' } ],
        int      => [ { type => 'Number' } ],
        bigint   => [ { type => 'Number' } ],
        bool     => [ { type => 'Toggle' } ],
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
