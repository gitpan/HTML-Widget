package HTML::Widget::Element::Upload;

use warnings;
use strict;
use base 'HTML::Widget::Element';

__PACKAGE__->mk_accessors(qw/comment label/);
__PACKAGE__->mk_attr_accessors(qw/accept maxlength size/);

=head1 NAME

HTML::Widget::Element::Upload - Upload Element

=head1 SYNOPSIS

    my $e = $widget->element( 'Upload', 'foo' );
    $e->comment('(Required)');
    $e->label('Foo');
    $e->accept('text/html');
    $e->maxlength(1000);
    $e->size(23);

=head1 DESCRIPTION

Upload Element.

Adding an Upload element automatically calls
C<$widget->enctype('multipart/form-data')> for you.

=head1 METHODS

=head2 $self->render( $widget, $value, $errors )

=cut

sub render {
    my ( $self, $w, $value, $errors ) = @_;

    $value = ref $value eq 'ARRAY' ? shift @$value : $value;

    my $l = $self->mk_label( $w, $self->label, $self->comment, $errors );
    my $i = $self->mk_input( $w, { type => 'file', value => $value }, $errors );
    $l ? ( $l->push_content($i) ) : ( $l = $i );
    my $e = $self->mk_error( $w, $errors );

    return $self->container( { element => $l, error => $e } );
}

=head1 AUTHOR

Sebastian Riedel, C<sri@oook.de>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;
