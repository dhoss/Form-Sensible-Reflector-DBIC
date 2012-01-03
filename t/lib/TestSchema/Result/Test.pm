package TestSchema::Result::Test;
use base qw/DBIx::Class/;
use DateTime;

__PACKAGE__->load_components(qw/ Core  /);
__PACKAGE__->table('user');
__PACKAGE__->add_columns(
    'id',
    {
        data_type   => 'int',
        is_auto_increment => 1,
        is_primary_key => 1,
    },
    'username',
    {
        data_type   => 'varchar',
        size        => '40',
        is_nullable => 0,
        validation  => {
            regex => qr/^(.+){3,}$/
        },

    },
	'file_upload',
	{
		data_type   => 'blob',
		is_nullable => 0,
	},
	'date',
	{
		data_type   => 'datetime',
		is_nullable => 0,
		default_form_value => DateTime->now,
        validation  => {
            regex => qr/^(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2}):(\d{2})$/,
        },
	},
	'big_text',
	{
		data_type   => 'text',
		is_nullable =>0,
		size        => '4096',
        validation  => {
            regex => qr/^(.+){3,}$/,
        },
	},
	'number',
	{
		data_type   => 'int',
		is_nullable => 0,
        validation => {
            regex => qr/^[0-9]+$/,
        },
	},
	'decimal',
	{
		data_type   => 'decimal',
		is_nullable => 0,
        validation  => {
            regex => qr/^(\d.+)\.(\d.+)$/,
        },
	},
	'big_number',
	{
		data_type   => 'bigint',
		is_nullabel => 0,
        validation  => {
            regex  => qr/^[0-9]+$/,
        },
	},
    'password',
    {
        data_type   => 'varchar',
        size        => '40',
        is_nullable => 0,
        validation => { 
            render_hints => { 
                field_type => 'password' 
            },
            regex => qr/^(?=.{8,})(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).*$/,
        }, 
    },
    'country_id',
    {
        data_type   => 'int',
        fs_select_value_column => 'id',
        fs_select_name_column => 'country',
        is_nullable => 1
    },
);
__PACKAGE__->set_primary_key('id');

__PACKAGE__->belongs_to('country' => 'TestSchema::Result::Country', 'country_id');

1;
