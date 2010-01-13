package Form::Sensible::Form::Reflector::DBIC;
use Moose;
use namespace::autoclean;
extends 'Form::Sensible::Form::Reflector';
use DateTime;
use Carp;

has 'schema' => (
    is         => 'rw',
    isa        => 'DBIx::Class::Schema',
    required   => 1,
    lazy       => 1,
    default    => sub { croak "No schema specified" }
);

has 'name' => (
    is         => 'rw',
    isa        => 'Str',
	required   => 1,
    lazy       => 1,
    default    => sub { croak "No form name specified" }
);


## otherwise return error string
sub get_all_fields {
    my $self = shift;
    my @definitions;
	my @columns = $self->schema->source( ucfirst $self->name )->columns;
    return @columns;
}
	
sub get_types {
    my $self = shift;
    return {
        varchar  => [ { type => 'Text' } ],
        text     => [ { type => 'LongText', size => '4098' } ],
        blob     => [ { type => 'FileSelector' } ],
        datetime => [ { type => 'Text', value => DateTime->now } ],
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
    return $types->{$sql_type};
}

__PACKAGE__->meta->make_immutable;

1;
