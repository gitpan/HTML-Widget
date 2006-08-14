use Test::More tests => 2;

use_ok("HTML::Widget");

use lib 't/lib';
use HTMLWidget::TestLib;

my $w = HTML::Widget->new;

$w->element( 'Textfield', 'foo' )->value('foo');

$w->filter( 'LowerCase', 'foo' );

# With mocked basic query
{
    my $query = HTMLWidget::TestLib->mock_query( {foo => 'Foo'} );

    my $f = $w->process($query);
    is( "$f", <<EOF, 'XML output is filled out form' );
<form id="widget" method="post"><fieldset><input class="textfield" id="widget_foo" name="foo" type="text" value="foo" /></fieldset></form>
EOF
}

