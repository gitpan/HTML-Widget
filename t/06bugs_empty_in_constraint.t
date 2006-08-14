use Test::More tests => 3;

use_ok('HTML::Widget');

use lib 't/lib';
use HTMLWidget::TestLib;

my $w = HTML::Widget->new;

$w->element( 'Textfield', 'foo' );

$w->constraint( In => 'foo' );

my $query = HTMLWidget::TestLib->mock_query({
    foo => 'yada', bar => '23',
});

my $f = $w->process( $query );

ok( $f->valid('foo') );

ok( ! $f->has_errors );
