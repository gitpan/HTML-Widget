package HTML::Widget::Element;

use warnings;
use strict;
use base 'HTML::Widget::Accessor';
use HTML::Element;
use HTML::Widget::Container;
use NEXT;

__PACKAGE__->mk_accessors(qw/name passive/);
__PACKAGE__->mk_attr_accessors(qw/class/);

=head1 NAME

HTML::Widget::Element - Element Base Class

=head1 SYNOPSIS

    my $e = $widget->element( $type, $name );
    $e->attributes( { class => 'foo' } );
    $e->name('bar');
    $e->class('foo');

=head1 DESCRIPTION

Element Base Class.

=head1 METHODS

=head2 new

=cut

sub new { shift->NEXT::new(@_)->attributes( {} ) }

=head2 $self->container($attributes)

Creates a new L<HTML::Widget::Container>.

=cut

sub container {
    my ( $self, $attributes ) = @_;
    return HTML::Widget::Container->new($attributes);
}

=head2 $self->id($widget)

Creates a element id.

=cut

sub id {
    my ( $self, $w, $id ) = @_;
    return $w->name  . '_' . ( $id || $self->name );
}

=head2 $self->init($widget)

Called once when process() gets called for the first time.

=cut

sub init { }

=head2 $self->mk_error( $w, $errors )

Creates a new L<HTML::Widget::Error>.

=cut

sub mk_error {
    my ( $self, $w, $errors ) = @_;

    return if ( !$w->{empty_errors} && (!defined($errors) || !scalar(@$errors)) );
    my $id        = $self->attributes->{id} || $self->id($w);
    my $cont_id   = $id . '_errors';
    my $container =
      HTML::Element->new( 'span', id => $cont_id, class => 'error_messages' );
    for my $error (@$errors) {
        my $e_id    = $id . '_error_' . lc( $error->{type} );
        my $e_class = lc( $error->{type} . '_errors' );
        my $e = HTML::Element->new( 'span', id => $e_id, class => $e_class );
        $e->push_content( $error->{message} );
        $container->push_content($e);
    }
    return $container;
}

=head2 $self->mk_input( $w, $attrs, $errors )

Creates a new input tag.

=cut

sub mk_input {
    my ( $self, $w, $attrs, $errors ) = @_;
    my $e    = HTML::Element->new('input');
    my $id   = $self->attributes->{id} || $self->id($w);
    my $type = ref $self;
    $type =~ s/^HTML::Widget::Element:://;
    $self->attributes->{class} ||= lc($type);
    $e->attr( id => $id ) unless $self->attributes->{id};
    $e->attr( name => $self->name );

    for my $key ( keys %$attrs ) {
        my $value = $attrs->{$key};
        $e->attr( $key, $value ) if $value;
    }
    $e->attr( $_ => ${ $self->attributes }{$_} )
      for ( keys %{ $self->attributes } );
    if ($errors) {
        my $err = HTML::Element->new( 'span', class => 'fields_with_errors' );
        $err->push_content($e);
        return $err;
    }
    return $e;
}

=head2 $self->mk_label( $w, $name )

Creates a new label tag.

=cut

sub mk_label {
    my ( $self, $w, $name, $comment, $errors ) = @_;
    return undef unless $name;
    my $for = $self->attributes->{id} || $self->id($w);
    my $id  = $for . '_label';
    my $e   = HTML::Element->new( 'label', for => $for, id => $id );
    if ($errors) {
        $e->attr( 'class' => 'labels_with_errors' );
    }
    $e->push_content($name);
    if ($comment) {
        my $c = HTML::Element->new(
            'span',
            id    => "$for\_comment",
            class => 'label_comments'
        );
        $c->push_content($comment);
        $e->push_content($c);
    }
    return $e;
}

=head2 name($name)

Contains the element name.

=head2 passive($passive)

Defines if element gets automatically rendered.

=head2 $self->prepare($widget)

Called whenever process() gets called.

=cut

sub prepare { }

=head2 $self->render

Render element.

=cut

sub render { }

=head1 AUTHOR

Sebastian Riedel, C<sri@oook.de>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;
