use Test::More tests => 3;

use Test::MockObject;

use_ok('HTML::Widget');

my $w = HTML::Widget->new;

$w->element( 'Textfield', 'year' );
$w->element( 'Textfield', 'month' );
$w->element( 'Textfield', 'day' );

$w->constraint( 'Date', 'year', 'month', 'day' );

# Valid
{
    my $query = Test::MockObject->new;
    my $data = { year => '2005', month => '12', day => '9' };
    $query->mock( 'param',
        sub { $_[1] ? ( return $data->{ $_[1] } ) : ( keys %$data ) } );
    my $f = $w->process($query);
    is( "$f", <<EOF, 'XML output is filled out form' );
<form action="/" id="widget" method="post"><fieldset><input class="textfield" id="widget_year" name="year" type="text" value="2005" /><input class="textfield" id="widget_month" name="month" type="text" value="12" /><input class="textfield" id="widget_day" name="day" type="text" value="9" /></fieldset></form>
EOF
}

# Invalid
{
    my $query = Test::MockObject->new;
    my $data = { year => '2005', month => 'foo', day => '500' };
    $query->mock( 'param',
        sub { $_[1] ? ( return $data->{ $_[1] } ) : ( keys %$data ) } );
    my $f = $w->process($query);
    is( "$f", <<EOF, 'XML output is filled out form' );
<form action="/" id="widget" method="post"><fieldset><span class="fields_with_errors"><input class="textfield" id="widget_year" name="year" type="text" value="2005" /></span><span class="error_messages" id="widget_year_errors"><span class="date_errors" id="widget_year_error_date">Invalid Input</span></span><span class="fields_with_errors"><input class="textfield" id="widget_month" name="month" type="text" value="foo" /></span><span class="error_messages" id="widget_month_errors"><span class="date_errors" id="widget_month_error_date">Invalid Input</span></span><span class="fields_with_errors"><input class="textfield" id="widget_day" name="day" type="text" value="500" /></span><span class="error_messages" id="widget_day_errors"><span class="date_errors" id="widget_day_error_date">Invalid Input</span></span></fieldset></form>
EOF
}
