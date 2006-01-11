use Test::More tests => 3;

use Test::MockObject;

use_ok('HTML::Widget');

my $w = HTML::Widget->new;

$w->element( 'Textfield', 'hour' );
$w->element( 'Textfield', 'minute' );
$w->element( 'Textfield', 'second' );

$w->constraint( 'Time', 'hour', 'minute', 'second' );

# Valid
{
    my $query = Test::MockObject->new;
    my $data = { hour => '6', minute => '12', second => '9' };
    $query->mock( 'param',
        sub { $_[1] ? ( return $data->{ $_[1] } ) : ( keys %$data ) } );
    my $f = $w->process($query);
    is( "$f", <<EOF, 'XML output is filled out form' );
<form action="/" id="widget" method="post"><fieldset><input class="textfield" id="widget_hour" name="hour" type="text" value="6" /><input class="textfield" id="widget_minute" name="minute" type="text" value="12" /><input class="textfield" id="widget_second" name="second" type="text" value="9" /></fieldset></form>
EOF
}

# Invalid
{
    my $query = Test::MockObject->new;
    my $data = { hour => '6', minute => '400', second => '5' };
    $query->mock( 'param',
        sub { $_[1] ? ( return $data->{ $_[1] } ) : ( keys %$data ) } );
    my $f = $w->process($query);
    is( "$f", <<EOF, 'XML output is filled out form' );
<form action="/" id="widget" method="post"><fieldset><span class="fields_with_errors"><input class="textfield" id="widget_hour" name="hour" type="text" value="6" /></span><span class="error_messages" id="widget_hour_errors"><span class="time_errors" id="widget_hour_error_time">Invalid Input</span></span><span class="fields_with_errors"><input class="textfield" id="widget_minute" name="minute" type="text" value="400" /></span><span class="error_messages" id="widget_minute_errors"><span class="time_errors" id="widget_minute_error_time">Invalid Input</span></span><span class="fields_with_errors"><input class="textfield" id="widget_second" name="second" type="text" value="5" /></span><span class="error_messages" id="widget_second_errors"><span class="time_errors" id="widget_second_error_time">Invalid Input</span></span></fieldset></form>
EOF
}
