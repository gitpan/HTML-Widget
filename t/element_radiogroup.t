use strict;
use warnings;

use Test::More tests => 5;

use HTML::Widget;
use lib 't/lib';
use HTMLWidget::TestLib;

my $w = HTML::Widget->new;

#     my $e = $widget->element( 'RadioGroup', 'name' ['foo', 'bar', 'baz'] );
#     $e->comment('(Required)');
#     $e->label('Foo');
#     $e->value('bar');

my $e = $w->element( 'RadioGroup', 'bar' )->values( [ 'opt1', 'opt2', 'opt3' ] )
    ->value('opt1');

# Without query
{
    my $f = $w->process;
    is( "$f", <<EOF, 'XML output is filled out form' );
<form id="widget" method="post"><fieldset><span><label for="widget_bar_1" id="widget_bar_1_label"><input checked="checked" class="radio" id="widget_bar_1" name="bar" type="radio" value="opt1" />Opt1</label><label for="widget_bar_2" id="widget_bar_2_label"><input class="radio" id="widget_bar_2" name="bar" type="radio" value="opt2" />Opt2</label><label for="widget_bar_3" id="widget_bar_3_label"><input class="radio" id="widget_bar_3" name="bar" type="radio" value="opt3" />Opt3</label></span></fieldset></form>
EOF
}

# With mocked basic query
{
    my $query = HTMLWidget::TestLib->mock_query( { bar => 'opt2' } );

    my $f = $w->process($query);
    is( "$f", <<EOF, 'XML output is filled out form' );
<form id="widget" method="post"><fieldset><span><label for="widget_bar_1" id="widget_bar_1_label"><input class="radio" id="widget_bar_1" name="bar" type="radio" value="opt1" />Opt1</label><label for="widget_bar_2" id="widget_bar_2_label"><input checked="checked" class="radio" id="widget_bar_2" name="bar" type="radio" value="opt2" />Opt2</label><label for="widget_bar_3" id="widget_bar_3_label"><input class="radio" id="widget_bar_3" name="bar" type="radio" value="opt3" />Opt3</label></span></fieldset></form>
EOF
}

# With label/legend
$e->label('Choose');
{
    my $f = $w->process;
    is( "$f", <<EOF, 'XML output is filled out form (label)' );
<form id="widget" method="post"><fieldset><label id="widget_bar_label">Choose<span><label for="widget_bar_1" id="widget_bar_1_label"><input checked="checked" class="radio" id="widget_bar_1" name="bar" type="radio" value="opt1" />Opt1</label><label for="widget_bar_2" id="widget_bar_2_label"><input class="radio" id="widget_bar_2" name="bar" type="radio" value="opt2" />Opt2</label><label for="widget_bar_3" id="widget_bar_3_label"><input class="radio" id="widget_bar_3" name="bar" type="radio" value="opt3" />Opt3</label></span></label></fieldset></form>
EOF
}

# With comment too
$e->comment('Informed');
{
    my $f = $w->process;
    is( "$f", <<EOF, 'XML output is filled out form (label+comment)' );
<form id="widget" method="post"><fieldset><label id="widget_bar_label">Choose<span class="label_comments" id="widget_bar_comment">Informed</span><span><label for="widget_bar_1" id="widget_bar_1_label"><input checked="checked" class="radio" id="widget_bar_1" name="bar" type="radio" value="opt1" />Opt1</label><label for="widget_bar_2" id="widget_bar_2_label"><input class="radio" id="widget_bar_2" name="bar" type="radio" value="opt2" />Opt2</label><label for="widget_bar_3" id="widget_bar_3_label"><input class="radio" id="widget_bar_3" name="bar" type="radio" value="opt3" />Opt3</label></span></label></fieldset></form>
EOF
}

# With error
$w->constraint( 'In' => 'bar' )->in('octopus');
{
    my $query = HTMLWidget::TestLib->mock_query( { bar => 'opt2' } );

    my $f = $w->process($query);
    is( "$f", <<EOF, 'XML output is filled out form (label+comment+error)' );
<form id="widget" method="post"><fieldset><label class="labels_with_errors" id="widget_bar_label">Choose<span class="label_comments" id="widget_bar_comment">Informed</span><span><label for="widget_bar_1" id="widget_bar_1_label"><input class="radio" id="widget_bar_1" name="bar" type="radio" value="opt1" />Opt1</label><label for="widget_bar_2" id="widget_bar_2_label"><input checked="checked" class="radio" id="widget_bar_2" name="bar" type="radio" value="opt2" />Opt2</label><label for="widget_bar_3" id="widget_bar_3_label"><input class="radio" id="widget_bar_3" name="bar" type="radio" value="opt3" />Opt3</label></span></label><span class="error_messages" id="widget_bar_errors"><span class="in_errors" id="widget_bar_error_in">Invalid Input</span></span></fieldset></form>
EOF
}
