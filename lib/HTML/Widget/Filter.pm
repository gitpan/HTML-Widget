package HTML::Widget::Filter;

use warnings;
use strict;
use base 'Class::Accessor::Chained::Fast';

__PACKAGE__->mk_accessors(qw/names/);

=head1 NAME

HTML::Widget::Filter - Filter Base Class

=head1 SYNOPSIS

    my $f = $widget->filter( $type, @names );
    $c->names(@names);

=head1 DESCRIPTION

Filter Base Class.

=head1 METHODS

=head2 $self->filter($value)

FIlter given value.

=cut

sub filter { return $_[0] }

=head2 $self->init($widget)

Called once when process() gets called for the first time.

=cut

sub init { }

=head2 $self->names(@names)

Contains names of params to filter.

=head2 $self->prepare($widget)

Called whenever process() gets called.

=cut

sub prepare { }

=head2 $self->process($params)

=cut

sub process {
    my ( $self, $params ) = @_;
    my @names = scalar @{ $self->names } ? @{ $self->names } : keys %$params;
    for my $name (@names) {
        my $values = $params->{$name};
        my @values = ref $values eq 'ARRAY' ? @$values : ($values);
        for my $value (@values) {
            $params->{$name} = $self->filter($value);
        }
    }
    use Data::Dumper;
}

=head1 AUTHOR

Sebastian Riedel, C<sri@oook.de>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;
