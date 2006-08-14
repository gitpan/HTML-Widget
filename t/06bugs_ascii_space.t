use Test::More tests => 5;

use_ok('HTML::Widget');

use lib 't/lib';
use HTMLWidget::TestLib;

my $w = HTML::Widget->new;

$w->element( 'Textfield', 'foo' );

$w->constraint( 'ASCII', 'foo' );

my $query = HTMLWidget::TestLib->mock_query({ foo => ' ' });

my $f = $w->process( $query );
is( "$f", <<EOF, 'XML output is filled out form' );
<form id="widget" method="post"><fieldset><input class="textfield" id="widget_foo" name="foo" type="text" value=" " /></fieldset></form>
EOF

ok( ! $f->has_errors );

ok( $f->valid('foo') );

ok( $f->param('foo') eq ' ' );

