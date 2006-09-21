package HTML::Widget::Accessor;

use warnings;
use strict;
use base 'Class::Accessor::Chained::Fast';
use Carp qw/croak/;

__PACKAGE__->mk_accessors(qw/attributes/);

*attrs = \&attributes;

=head1 NAME

HTML::Widget::Accessor - Accessor Class

=head1 SYNOPSIS

    use base 'HTML::Widget::Accessor';

=head1 DESCRIPTION

Accessor Class.

=head1 METHODS

=head2 attributes

=head2 attrs

Arguments: \%attributes

Return Value: \%attributes

The recommended way of setting attributes is to assign directly to a 
hash-ref key, rather than passing an entire hash-ref, which would overwrite 
any existing attributes.

    # recommended - preserves existing key/value's
    $w->attributes->{key} = $value;
    
    # NOT recommended - deletes existing key/value's
    $w->attributes( { key => $value } );

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

=head2 mk_attr_accessors

Arguments: @names

Return Value: @names

=cut

sub mk_attr_accessors {
    my ( $self, @names ) = @_;
    my $class = ref $self || $self;
    for my $name (@names) {
        no strict 'refs';
        *{"$class\::$name"} = sub {
            return ( $_[0]->{attributes}->{$name} || $_[0] ) unless @_ > 1;
            my $self = shift;
            $self->{attributes}->{$name} = ( @_ == 1 ? $_[0] : [@_] );
            return $self;
            }
    }
}

sub _instantiate {
    my ( $self, $class, @args ) = @_;
    my $file = $class . ".pm";
    $file =~ s{::}{/}g;
    eval { require $file };
    croak qq/Couldn't load class "$class", "$@"/ if $@;
    return $class->new(@args);
}

=head1 AUTHOR

Sebastian Riedel, C<sri@oook.de>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;
