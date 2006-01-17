package HTML::Widget::Element::Submit;

use warnings;
use strict;
use base 'HTML::Widget::Element';
use NEXT;

__PACKAGE__->mk_accessors(qw/value/);

=head1 NAME

HTML::Widget::Element::Submit - Submit Element

=head1 SYNOPSIS

    $e = $widget->element( 'Submit', 'foo' );
    $e->value('bar');

=head1 DESCRIPTION

Submit Element.

=head1 METHODS

=head2 new

=cut

sub new {
    shift->NEXT::new(@_)->value(1);
}

=head2 $self->render( $widget, $value )

=cut

sub render {
    my ( $self, $w, $value ) = @_;

    $value = ref $value eq 'ARRAY' ? shift @$value : $value;

    $value ||= $self->value;
    my $i = $self->mk_input( $w, { type => 'submit', value => $value } );

    return $self->container( { element => $i } );
}

=head1 AUTHOR

Sebastian Riedel, C<sri@oook.de>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;
