package HTML::Widget::Element;

use warnings;
use strict;
use base qw/HTML::Widget::Accessor Class::Data::Accessor/;
use HTML::Element;
use HTML::Widget::Container;
use NEXT;

__PACKAGE__->mk_classaccessor( container_class => 'HTML::Widget::Container' );

__PACKAGE__->mk_accessors(qw/name passive/);
__PACKAGE__->mk_attr_accessors(qw/class/);

=head1 NAME

HTML::Widget::Element - Element Base Class

=head1 SYNOPSIS

    my $e = $widget->element( $type, $name );
    $e->attributes->{class} = 'foo';
    $e->name('bar');
    $e->class('foo');

=head1 DESCRIPTION

Element Base Class.

=head1 METHODS

=head2 new

=cut

sub new { shift->NEXT::new(@_)->attributes( {} ) }

=head2 attributes

=head2 attrs

Arguments: \%attributes

Return Value: \%attributes

The recommended way of setting attributes is to assign directly to a 
hash-ref key, rather than passing an entire hash-ref, which would overwrite 
any existing attributes.

    # recommended - preserves existing key/value's
    $e->attributes->{key} = $value;
    
    # NOT recommended - deletes existing key/value's
    $e->attributes( { key => $value } );

However, when a value is set in this recommended way, the object is not 
returned, so cannot be used for further chained method calls.

    $w->element( 'Textfield', 'foo' )
        ->size( 10 )
        ->attributes->{'disabled'} = 'disabled';
    # we cannot chain any further method calls after this

Therefore, to set multiple attributes, it is recommended you store the 
appropriate object, and call L</attributes> multiple times.

    my $e = $w->element( 'Textfield', 'foo' )->size( 10 );
    
    $e->attributes->{'disabled'} = 'disabled';
    $e->attributes->{'id'}       = 'login';

L</attrs> is an alias for L</attributes>.

=head2 container

Arguments: \%attributes

Return Value: $container

Creates a new $container_class. Defaults to L<HTML::Widget::Container>.

=cut

sub container {
    my ( $self, $attributes ) = @_;
    my $class = $self->container_class || 'HTML::Widget::Container';
    my $file = $class . ".pm";
    $file =~ s{::}{/}g;
    eval { require $file };
    die "Unable to load element container class $class: $@" if $@;
    return $class->new( { passive => $self->passive, %$attributes } );
}

=head2 id

Arguments: $widget

Return Value: $id

Creates a element id.

=cut

sub id {
    my ( $self, $w, $id ) = @_;
    return $w->name . '_' . ( $id || $self->name );
}

=head2 init

Arguments: $widget

Called once when process() gets called for the first time.

=cut

sub init { }

=head2 mk_error

Arguments: $widget, \@errors

Return Value: $error

Creates a new L<HTML::Widget::Error>.

=cut

sub mk_error {
    my ( $self, $w, $errors ) = @_;

    return
        if ( !$w->{empty_errors}
        && ( !defined($errors) || !scalar(@$errors) ) );
    my $id        = $self->attributes->{id} || $self->id($w);
    my $cont_id   = $id . '_errors';
    my $container = HTML::Element->new(
        'span',
        id    => $cont_id,
        class => 'error_messages'
    );
    for my $error (@$errors) {
        my $e_id    = $id . '_error_' . lc( $error->{type} );
        my $e_class = lc( $error->{type} . '_errors' );
        my $e = HTML::Element->new( 'span', id => $e_id, class => $e_class );
        $e->push_content( $error->{message} );
        $container->push_content($e);
    }
    return $container;
}

=head2 mk_input

Arguments: $widget, \%attributes, \@errors

Return Value: $input_tag

Creates a new input tag.

=cut

sub mk_input {
    my ( $self, $w, $attrs, $errors ) = @_;

    return $self->mk_tag( $w, 'input', $attrs, $errors );
}

=head2 mk_tag

Arguments: $widget, $tagtype, \%attributes, \@errors

Return Value: $element_tag

Creates a new tag.

=cut

sub mk_tag {
    my ( $self, $w, $tag, $attrs, $errors ) = @_;
    my $e    = HTML::Element->new($tag);
    my $id   = $self->attributes->{id} || $self->id($w);
    my $type = ref $self;
    $type =~ s/^HTML::Widget::Element:://;
    $type =~ s/::/_/g;
    $self->attributes->{class} ||= lc($type);
    $e->attr( id => $id ) unless $self->attributes->{id} || $w->{explicit_ids};
    $e->attr( name => $self->name );

    for my $key ( keys %$attrs ) {
        my $value = $attrs->{$key};
        $e->attr( $key, $value ) if defined $value;
    }
    $e->attr( $_ => ${ $self->attributes }{$_} )
        for ( keys %{ $self->attributes } );

    return $e;
}

=head2 mk_label

Arguments: $widget, $name, $comment, \@errors

Return Value: $label_tag

Creates a new label tag.

=cut

sub mk_label {
    my ( $self, $w, $name, $comment, $errors ) = @_;
    return unless defined $name;
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

=head2 name

Arguments: $name

Return Value: $name

Contains the element name.

=head2 passive

Arguments: $bool

Return Value: $bool

Defines if element gets automatically rendered.

=head2 prepare

Arguments: $widget

Called whenever $widget->process() gets called, before $element->process().

=cut

sub prepare { }

=head2 process

Arguments: \%params, \@uploads

Return Value: \@errors

Called whenever $widget->process()

Returns an arrayref of L<HTML::Widget::Error> objects.

=cut

sub process { }

=head2 containerize

Arguments: $widget, $value, \@errors

Return Value: $container_tag

Containerize the element, label and error for later rendering. Uses HTML::Widget::Container by default, but this can be over-ridden on a class or instance basis via L<container_class>.

=cut

sub containerize { }

=head2 container_class

Arguments: $class

Return Value: $class

Contains the class to use for contain the element which then get rendered. Defaults to L<HTML::Widget::Container>. C<container_class> can be set at a class or instance level:

  HTML::Widget::Element->container_class('My::Container'); 
  # Override default to custom class
  
  HTML::Widget::Element::Password->container_class(undef); 
  # Passwords use the default class
   
  $w->element('Textfield')->name('foo')->container_class->('My::Other::Container'); 
  # This element only will use My::Other::Container to render

=cut

sub container_class {
    my ($self) = shift;

    if ( not $_[0] and @_ >= 1 ) {
        delete $self->{container_class};
    }

    return $self->_container_class_accessor(@_);
}

=head2 find_elements

Return Value: \@elements

For non-block-container elements, simply returns a one-element list
containing this element.

=cut

sub find_elements { return (shift); }

=head1 AUTHOR

Sebastian Riedel, C<sri@oook.de>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;
