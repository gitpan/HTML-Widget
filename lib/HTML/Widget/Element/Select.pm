package HTML::Widget::Element::Select;

use warnings;
use strict;
use base 'HTML::Widget::Element';

*value = \&selected;

__PACKAGE__->mk_accessors(qw/comment label options selected/);
__PACKAGE__->mk_attr_accessors(qw/size/);

=head1 NAME

HTML::Widget::Element::Select - Select Element

=head1 SYNOPSIS

    my $e = $widget->element( 'Select', 'foo' );
    $e->comment('(Required)');
    $e->label('Foo');
    $e->size(23);
    $e->options( foo => 'Foo', bar => 'Bar' );
    $e->selected(qw/foo bar/);

=head1 DESCRIPTION

Select Element.

=head1 METHODS

=head2 comment

Add a comment to this Element.

=head2 label

This label will be placed next to your Element.

=head2 size

The size of a select element determines whether it will be displayed as a 
dropdown (size = 1), or a multi-select list element. The default is 1.

=head2 options

A list of options in key => value format. Each key is the unique id of an
option tag, and its corresponding value is the text displayed in the element.

=head2 selected

=head2 value (alias)

A list of keys (unique option ids) which will be pre-set to "selected".
Can also be addressed as value for consistency with the other elements

=head2 $self->render( $widget, $value, $errors )

=cut

sub render {
    my ( $self, $w, $value, $errors ) = @_;

    my $options = $self->options;
    my @options = ref $options eq 'ARRAY' ? @$options : ();
    my @o;
    my @values;
    if ($value) {
        @values = ref $value eq 'ARRAY' ? @$value : ($value);
    }
    else {
        @values =
          ref $self->selected eq 'ARRAY'
          ? @{ $self->selected }
          : ( $self->selected );
    }

    # You might be tempted to say 'while ( my $key = shift( @temp_options ) )'
    # here, but then that falls if the first element is a 0 :-) So we do the
    # following bit of nastiness instead:

    my @temp_options = @options;
    while ( scalar @temp_options ) {

        my $key    = shift(@temp_options);
        my $value  = shift(@temp_options);
        my $option = HTML::Element->new( 'option', value => $key );
        for my $val (@values) {
            if ( ( defined $val ) && ( $val eq $key ) ) {
                $option->attr( selected => 'selected' );
                last;
            }
        }
        $option->push_content($value);
        push @o, $option;
    }

    my $label = $self->mk_label( $w, $self->label, $self->comment, $errors );

    $self->attributes->{class} ||= 'select';
    my $selectelm = HTML::Element->new('select');
    $selectelm->push_content(@o);
    if ($label) {
        $label->push_content($selectelm);
    }

    #    $l ? ( $l->push_content($i) ) : ( $l = $i );
    my $id = $self->id($w);
    $selectelm->attr( id   => $id );
    $selectelm->attr( name => $self->name );

    $selectelm->attr( $_ => ${ $self->attributes }{$_} )
      for ( keys %{ $self->attributes } );

    #    $l->push_content($i);

    my $e = $self->mk_error( $w, $errors );

    return $self->container( { element => $label || $selectelm, error => $e } );
}

=head1 AUTHOR

Sebastian Riedel, C<sri@oook.de>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;
