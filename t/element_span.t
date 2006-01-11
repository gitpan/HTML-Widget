use Test::More tests => 2;

use Test::MockObject;

use_ok('HTML::Widget');

my $w = HTML::Widget->new->tag('span')->subtag('span');

$w->element( 'Span', 'foo' )->content('foo');
$w->element( 'Span', 'bar' );

# Without query
{
    my $f = $w->process;
    is( "$f", <<EOF, 'XML output is filled out form' );
<span id="widget"><span><span class="span" id="widget_foo">foo</span><span class="span" id="widget_bar"></span></span></span>
EOF
}
