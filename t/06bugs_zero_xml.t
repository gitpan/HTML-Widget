use Test::More tests => 7;

use_ok('HTML::Widget');

use lib 't/lib';
use HTMLWidget::TestLib;

my $w1 = HTML::Widget->new;

$w1->element( 'Textfield', 'foo' );
$w1->element( 'Textfield', '0' );

# Valid
{
    my $query = HTMLWidget::TestLib->mock_query({
        foo => 'yada',
        0   => 'a',
    });

    my $result = $w1->process($query);

    is( "$result", <<EOF, 'XML output is filled out form' );
<form id="widget" method="post"><fieldset><input class="textfield" id="widget_foo" name="foo" type="text" value="yada" /><input class="textfield" id="widget_0" name="0" type="text" value="a" /></fieldset></form>
EOF

    ok( $result->valid(0) );
    
    ok( ! $result->has_errors(0) );
}

# Embed test
{
    my $query = HTMLWidget::TestLib->mock_query({
        foo => 'yada',
        0   => 'a',
    });

    my $w2 = new HTML::Widget;
   
    $w1->name('embed');
    
    $w2->embed($w1);
    
    my $result = $w2->process($query);

    is( "$result", <<EOF, 'XML output is filled out form' );
<form id="widget" method="post"><fieldset id="widget_embed"><input class="textfield" id="widget_embed_foo" name="foo" type="text" value="yada" /><input class="textfield" id="widget_embed_0" name="0" type="text" value="a" /></fieldset></form>
EOF

    ok( $result->valid(0) );
    
    ok( ! $result->has_errors(0) );
}
