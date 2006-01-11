package HTML::Widget::Result;

use warnings;
use strict;
use base 'HTML::Widget::Accessor';
use HTML::Widget::Container;
use HTML::Element;

__PACKAGE__->mk_accessors(qw/attributes container legend subcontainer strict/);
__PACKAGE__->mk_attr_accessors(qw/action enctype id method empty_errors/);

use overload '""' => sub { return shift->as_xml }, fallback => 1;

*attrs       = \&attributes;
*name        = \&id;
*error       = \&errors;
*has_error   = \&has_errors;
*have_errors = \&has_errors;
*element     = \&elements;
*parameters  = \&params;
*tag         = \&container;
*subtag      = \&subcontainer;

=head1 NAME

HTML::Widget::Result - Result Class

=head1 SYNOPSIS

see L<HTML::Widget>

=head1 DESCRIPTION

Result Class.

=head1 METHODS

=head2 $self->action($action)

Contains the form action.

=head2 $self->as_xml

Returns xml.

=cut

sub as_xml {
    my $self = shift;

    my $c = HTML::Element->new( $self->container, id => $self->name );
    $self->attributes( {} ) unless $self->attributes;
    $c->attr( $_ => ${ $self->attributes }{$_} )
      for ( keys %{ $self->attributes } );

    my %javascript;
    if ( @{ $self->{_embedded} } ) {
        for my $embedded ( @{ $self->{_embedded} } ) {
            for my $js_callback ( @{ $self->{_js_callbacks} } ) {
                my $javascript = $js_callback->( $embedded->name );
                for my $key ( keys %$javascript ) {
                    $javascript{$key} .= $javascript->{$key}
                      if $javascript->{$key};
                }
            }
            next unless $embedded->{_elements};
            my $sc =
              HTML::Element->new( $self->subcontainer, id => $embedded->name );
            if ( my $legend = $embedded->legend ) {
                my $l =
                  HTML::Element->new( 'legend',
                    id => $embedded->name . "\_legend" );
                $l->push_content($legend);
                $sc->push_content($l);
            }
            my $oldname = $embedded->name;
            for my $element ( @{ $embedded->{_elements} } ) {
                my $value  = undef;
                my $name   = $element->{name};
                my $params = $self->{_params};
                $value = $params->{$name} if ( $name && $params );
                my $container =
                  $element->render( $embedded, $value,
                    $self->{_errors}->{$name} );
                $container->{javascript} ||= '';
                $container->{javascript} .= $javascript{$name}
                  if $javascript{$name};
                $sc->push_content( $container->as_list )
                  unless $element->passive;
            }
            $embedded->name($oldname);
            $c->push_content($sc);
        }
    }
    else {
        for my $js_callback ( @{ $self->{_js_callbacks} } ) {
            my $javascript = $js_callback->( $self->name );
            for my $key ( keys %$javascript ) {
                $javascript{$key} .= $javascript->{$key} if $javascript->{$key};
            }
        }
        my $sc = HTML::Element->new( $self->subcontainer );
        if ( my $legend = $self->legend ) {
            my $id = $self->name;
            my $l = HTML::Element->new( 'legend', id => "$id\_legend" );
            $l->push_content($legend);
            $sc->push_content($l);
        }
        for my $element ( @{ $self->{_elements} } ) {
            my $value  = undef;
            my $name   = $element->{name};
            my $params = $self->{_params};
            $value = $params->{$name} if ( $name && $params );
            my $container =
              $element->render( $self, $value, $self->{_errors}->{$name} );
            $container->{javascript} ||= '';
            $container->{javascript} .= $javascript{$name}
              if $javascript{$name};
            $sc->push_content( $container->as_list ) unless $element->passive;
        }
        $c->push_content($sc);
    }
    return $c->as_XML;
}

=head2 $self->container($tag)

Contains the container tag.

=head2 $self->enctype($enctype)

Contains the form encoding type.

=head2 $self->error( $name, $type )
=head2 $self->errors( $name, $type )

Returns a list of L<HTML::Widget::Error> objects.

    my @errors = $form->errors;
    my @errors = $form->errors('foo');
    my @errors = $form->errors( 'foo', 'ASCII' );

=cut

sub errors {
    my ( $self, $name, $type ) = @_;
    my $errors = [];
    my @names = $name || keys %{ $self->{_errors} };
    if ($name) { return 0 unless $self->{_errors}->{$name} }
    for my $n (@names) {
        for my $error ( @{ $self->{_errors}->{$n} } ) {
            if ($type) { next unless $error->{type} ne $type }
            push @$errors, $error;
        }
    }
    return @$errors;
}

=head2 $self->element($name)
=head2 $self->elements($name)

Returns a L<HTML::Widget::Container> object for element
or a list of L<HTML::Widget::Container> objects for form.

    my @form = $f->element;
    my $age  = $f->element('age');

=cut

sub elements {
    my ( $self, $name ) = @_;
    my %javascript;
    for my $js_callback ( @{ $self->{_js_callbacks} } ) {
        my $javascript = $js_callback->( $self->name );
        for my $key ( keys %$javascript ) {
            $javascript{$key} .= $javascript->{$key} if $javascript->{$key};
        }
    }
    my @form;
    for my $element ( @{ $self->{_elements} } ) {
        my $value = undef;
        my $ename = $element->{name};
        next if ( ($name) && ( $ename ne $name ) );
        my $params = $self->{_params};
        $value = $params->{$ename} if ( $ename && $params );
        my $container =
          $element->render( $self, $value, $self->{_errors}->{$ename} );
        $container->{javascript} ||= '';
        $container->{javascript} .= $javascript{$ename} if $javascript{$ename};
        return $container if $name;
        push @form, $container;
    }
    return @form;
}

=head2 $self->empty_errors(1)

Create spans for errors even when there's no errors.. (For AJAX validation validation)

=head2 $self->has_error($name);
=head2 $self->has_errors($name);
=head2 $self->have_errors($name);

Returns a list of element names.

    my @names = $form->has_errors;
    my $error = $form->has_errors($name);

=cut

sub has_errors {
    my ( $self, $name ) = @_;
    my @names = keys %{ $self->{_errors} };
    return @names unless $name;
    return 1 if grep { /$name/ } @names;
    return 0;
}

=head2 $self->id($id)

Contains the widget id.

=head2 $self->legend($legend)

Contains the legend.

=head2 $self->method($method)

Contains the form method.

=head2 $self->param($name)

Returns valid parameters with a CGI.pm-compatible param method. (read-only)

=cut

sub param {
    my $self = shift;

    if ( @_ == 1 ) {

        my $param = shift;

        my $valid = $self->valid($param);
        if ( !$valid || ( !exists $self->{_params}->{$param} ) ) {
            return wantarray ? () : undef;
        }

        if ( ref $self->{_params}->{$param} eq 'ARRAY' ) {
            return (wantarray)
              ? @{ $self->{_params}->{$param} }
              : $self->{_params}->{$param}->[0];
        }
        else {
            return (wantarray)
              ? ( $self->{_params}->{$param} )
              : $self->{_params}->{$param};
        }
    }

    return $self->valid;
}

=head2 $self->params($params)
=head2 $self->parameters($params)

Returns validated params as hashref.

=cut

sub params {
    my $self  = shift;
    my @names = $self->valid;
    my %params;
    for my $name (@names) {
        $params{$name} = $self->param($name);
    }
    return \%params;
}

=head2 $self->subcontainer($tag)

Contains the subcontainer tag.

=head2 $self->strict($strict)

Only consider parameters that pass at least one constraint valid.

=head2 $self->valid

Returns a list of element names.

    my @names = $form->valid;
    my $valid = $form->valid($name);

=cut

sub valid {
    my ( $self, $name ) = @_;
    my @errors = $self->has_errors;
    my @names;
    if ( $self->strict ) {
        for my $constraint ( @{ $self->{_constraints} } ) {
            my $names = $constraint->names;
            push @names, @$names if $names;
        }
    }
    else {
        @names = keys %{ $self->{_params} };
    }
    my %valid;
  CHECK: for my $name (@names) {
        for my $error (@errors) {
            next CHECK if $name eq $error;
        }
        $valid{$name}++;
    }
    my @valid = keys %valid;
    return @valid unless $name;
    return 1 if grep { /$name/ } @valid;
    return 0;
}

=head1 AUTHOR

Sebastian Riedel, C<sri@oook.de>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;
