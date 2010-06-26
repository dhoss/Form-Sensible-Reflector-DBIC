package TestSchema::Result::TestRel;
use base qw/DBIx::Class::Core/;
use DateTime;

__PACKAGE__->table('user_posts');
__PACKAGE__->add_columns(
    'postid',
    {
        data_type => 'int',
        is_auto_increment => 1,
    },
    'author',
    {
        data_type   => 'varchar',
        is_nullable => 0,
        validation => {
            regex => qr/^(.+){3,}$/,
        }

    },
	'created',
	{
		data_type   => 'datetime',
		is_nullable => 0,
		default_form_value => DateTime->now,
        validation  => {
            regex => qr/^(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2}):(\d{2})$/,
        },
	},
	'body',
	{
		data_type   => 'text',
		is_nullable =>0,
		size        => '4096',
        validation  => {
            regex => qr/^(.+){3,}$/,
        },
	},
	'title',
	{
		data_type   => 'varchar',
		is_nullable => 0,
        validation => {
            regex => qr/^(.+){3,}$/,
        },
	},
);

__PACKAGE__->set_primary_key('postid');

__PACKAGE__->belongs_to('author' => 'TestSchema::Result::Test', 
    {
        'foreign.username' => 'self.author',
    },
);

1;
