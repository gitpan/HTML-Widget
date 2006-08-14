use Test::More tests => 3;

use_ok('HTML::Widget');

use lib 't/lib';
use HTMLWidget::TestLib;

my $w = HTML::Widget->new;

$w->element( 'Textfield', 'foo' );

$w->constraint( '+HTMLWidget::CustomConstraint', 'foo' );

# Valid
{
    my $query = HTMLWidget::TestLib->mock_query({ foo => 23 });

    my $f = $w->process($query);
    is( "$f", <<EOF, 'XML output is filled out form' );
<form id="widget" method="post"><fieldset><input class="textfield" id="widget_foo" name="foo" type="text" value="23" /></fieldset></form>
EOF
}

# Invalid
{
    my $query = HTMLWidget::TestLib->mock_query({ foo => 'yada' });

    my $f = $w->process($query);
    is( "$f", <<EOF, 'XML output is filled out form' );
<form id="widget" method="post"><fieldset><span class="fields_with_errors"><input class="textfield" id="widget_foo" name="foo" type="text" value="yada" /></span><span class="error_messages" id="widget_foo_errors"><span class="htmlwidget_customconstraint_errors" id="widget_foo_error_htmlwidget_customconstraint">Invalid Input</span></span></fieldset></form>
EOF
}

