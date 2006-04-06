use Test::More tests => 3;

use_ok('HTML::Widget');

use lib 't/lib';
use HTMLWidget::TestLib;

my $w = HTML::Widget->new;

$w->element( 'Submit', 'foo' )->value('foo');
$w->element( 'Submit', 'bar' );
$w->element( 'Submit', 'foobar' )->src('http://localhost/test.jpg');

$w->constraint( 'Integer', 'foo' );
$w->constraint( 'Integer', 'bar' );

# Without query
{
    my $f = $w->process;
    is( "$f", <<EOF, 'XML output is filled out form' );
<form action="/" id="widget" method="post"><fieldset><input class="submit" id="widget_foo" name="foo" type="submit" value="foo" /><input class="submit" id="widget_bar" name="bar" type="submit" value="1" /><input class="submit" id="widget_foobar" name="foobar" src="http://localhost/test.jpg" type="image" value="1" /></fieldset></form>
EOF
}

# With mocked basic query
{
    my $query = HTMLWidget::TestLib->mock_query({
        foo => 'yada', bar => '23',
    });

    my $f = $w->process($query);
    is( "$f", <<EOF, 'XML output is filled out form' );
<form action="/" id="widget" method="post"><fieldset><input class="submit" id="widget_foo" name="foo" type="submit" value="yada" /><input class="submit" id="widget_bar" name="bar" type="submit" value="23" /><input class="submit" id="widget_foobar" name="foobar" src="http://localhost/test.jpg" type="image" value="1" /></fieldset></form>
EOF
}
