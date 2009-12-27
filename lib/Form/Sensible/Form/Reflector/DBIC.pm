package Form::Sensible::Form::Reflector::DBIC;
use Moose;
use namespace::autoclean;
use Form::Sensible::Form;
use Form::Sensible::Field;
use Form::Sensible::Field::Number;
use Form::Sensible::Field::Select;
use Form::Sensible::Field::Text;
use Form::Sensible::Field::LongText;
use Form::Sensible::Field::Toggle;
use Form::Sensible::Field::Trigger;
use Form::Sensible::Field::SubForm;
use DateTime;

has 'sql_types' => (
    is         => 'ro',
    isa        => 'HashRef[ArrayRef]',
    lazy_build => 1,
);

has 'translated' => (
    is         => 'rw',
    isa        => 'HashRef',
);

has 'schema' => (
    is         => 'rw',
    isa        => 'DBIx::Class::Schema',
    required   => 1,
    lazy_build => 1,
);

has 'name' => (
    is         => 'rw',
    isa        => 'Str',
	required   => 1,
    lazy_build => 1,
);


sub create_form {
    my ( $self ) = @_;
    my @typemap = $self->map_types;
	my $structure =  $typemap[0];
    my $schema  = $self->schema; #delete $form_structure->{'schema'};
    my $name    = $self->name; #delete $form_structure->{'name'};
    $self->schema($schema);
    $self->name($name);
    Form::Sensible->create_form( $structure );
}

## translate types
## return HoA if successful,
## otherwise return error string
sub map_types {
    my $self = shift;
    my @definitions;
	my @columns = $self->schema->source( ucfirst $self->name )->columns;
	for   ( @columns ) {
		push @definitions, { name => $_, %{ $self->schema->source( ucfirst $self->name )->column_info($_) } };
	}
	my $type;
    my $class;
    my $class_type;
    my @translated;
    my @fields;
	for my $i ( 0 .. $#definitions ) {

        $type       = $self->translate( $definitions[$i]->{data_type} );
        #eval { require $class_type };
        #unless ($@) {
        #}
        #else {
        #    return $@;
        #}
        # oughta make this smarter...
        push @fields,   { name => $definitions[$i]->{'name'}, field_class => $type->[0]->{'type'}, size => $definitions[$i]->{'size'} };
	    # also, not a fan of this
		if ( $definitions[$i]->{'name'} eq "password" ) {
			push @fields, { name => $definitions[$i]->{'name'}, field_class => $type->[0]->{'type'}, render_hints => { field_type => 'password' }, 
			size => $definitions[$i]->{'size'} }; 
        }
        push @fields,   { name => 'Submit',                 , field_class => 'Trigger' };
	}

	push @translated, { name => $self->name, fields => \@fields };
	return @translated;

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

sub translate {
    my ( $self, $sql_type ) = @_;
    ## big ass hash for mapping sql->form types
    ## use respective DBMS role, call ->get_types
    my $types = $self->get_types;
    return $types->{$sql_type};
}

__PACKAGE__->meta->make_immutable;

1;
