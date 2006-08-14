use Test::More tests => 3;

use_ok('HTML::Widget');

my $w = HTML::Widget->new;

$w->element( 'Select', 'foo' );
$w->element( 'Select', 'bar' )->options();

eval {
    my $f = $w->process();

    is( "$f", <<EOF, 'XML output is filled out form' );
<form id="widget" method="post"><fieldset><select class="select" id="widget_foo" name="foo"></select><select class="select" id="widget_bar" name="bar"></select></fieldset></form>
EOF
};

ok( ! $@ );
