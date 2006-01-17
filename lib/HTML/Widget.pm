package HTML::Widget;

use warnings;
use strict;
use base 'HTML::Widget::Accessor';
use HTML::Widget::Result;
use Scalar::Util 'blessed';

__PACKAGE__->mk_accessors(
    qw/container indicator legend query subcontainer uploads strict empty_errors/
);
__PACKAGE__->mk_attr_accessors(qw/action enctype id method/);

use overload '""' => sub { return shift->attributes->{id} }, fallback => 1;

*const  = \&constraint;
*elem   = \&element;
*name   = \&id;
*tag    = \&container;
*subtag = \&subcontainer;
*result = \&process;
*indi   = \&indicator;

our $VERSION = '1.02';

=head1 NAME

HTML::Widget - HTML Widget And Validation Framework

=head1 SYNOPSIS

    use HTML::Widget;

    # Create a widget
    my $w = HTML::Widget->new('widget')->method('get')->action('/');

    # Add some elements
    $w->element( 'Textfield', 'age' )->label('Age')->size(3);
    $w->element( 'Textfield', 'name' )->label('Name')->size(60);
    $w->element( 'Submit', 'ok' )->value('OK');

    # Add some constraints
    $w->constraint( 'Integer', 'age' )->message('No integer.');
    $w->constraint( 'Not_Integer', 'name' )->message('Integer.');
    $w->constraint( 'All', 'age', 'name' )->message('Missing value.');

    # Add some filters
    $w->filter('Whitespace');

    # Process
    my $result = $w->process;
    my $result = $w->process($query);


    # Check validation results
    my @valid_fields   = $result->valid;
    my $is_valid       = $result->valid('foo');
    my @invalid_fields = $result->have_errors;
    my $is_invalid     = $result->has_errors('foo');;

    # CGI.pm-compatible! (read-only)
    my $value  = $result->param('foo');
    my @params = $result->param;

    # Catalyst::Request-compatible
    my $value = $result->params->{foo};
    my @params = keys %{ $result->params };


    # Merge widgets (constraints and elements will be appended)
    $widget->merge($other_widget);


    # Embed widgets (as fieldset)
    $widget->embed($other_widget);


    # Complete xml result
    [% result %]
    [% result.as_xml %]


    # Iterate over elements
    <form action="/foo" method="get">
    [% FOREACH element = result.elements %]
        [% element.field_xml %]
        [% element.error_xml %]
    [% END %]
    </form>


    # Iterate over validation errors
    [% FOREACH element = result.have_errors %]
        <p>
        [% element %]:<br/>
        <ul>
        [% FOREACH error = result.errors(element) %]
            <li>
                [% error.name %]: [% error.message %] ([% error.type %])
            </li>
        [% END %]
        </ul>
        </p>
    [% END %]

    <p><ul>
    [% FOREACH element = result.have_errors %]
        [% IF result.error( element, 'Integer' ) %]
            <li>[% element %] has to be an integer.</li>
        [% END %]
    [% END %]
    </ul></p>

    [% FOREACH error = result.errors %]
        <li>[% error.name %]: [% error.message %] ([% error.type %])</li>
    [% END %]


    # XML output looks like this (easy to theme with css)
    <form action="/foo/bar" id="widget" method="post">
        <fieldset>
            <label for="widget_age" id="widget_age_label"
              class="labels_with_errors">
                Age
                <span class="label_comments" id="widget_age_comment">
                    (Required)
                </span>
                <span class="fields_with_errors">
                    <input id="widget_age" name="age" size="3" type="text"
                      value="24" class="Textfield" />
                </span>
            </label>
            <span class="error_messages" id="widget_age_errors">
                <span class="Regex_errors" id="widget_age_error_Regex">
                    Contains digit characters.
                </span>
            </span>
            <label for="widget_name" id="widget_name_label">
                Name
                <input id="widget_name" name="name" size="60" type="text"
                  value="sri" class="Textfield" />
                <span class="error_messages" id="widget_name_errors"></span>
            </label>
            <input id="widget_ok" name="ok" type="submit" value="OK" />
        </fieldset>
    </form>

=head1 DESCRIPTION

Create easy to maintain HTML widgets!

Everything is optional, use validation only or just generate forms,
you can embed and merge them later.

The API was designed similar to other popular modules like
L<Data::FormValidator> and L<FormValidator::Simple>,
L<HTML::FillInForm> is also built in (and much faster).

This Module is very powerful, don't misuse it as a template system!

=head1 METHODS

=head2 new

=cut

sub new {
    my ( $self, $name ) = @_;
    $self = bless {}, ( ref $self || $self );
    $self->container('form');
    $self->subcontainer('fieldset');
    $self->name( $name || 'widget' );
    return $self;
}

=head1 $self->action($action)

Contains the form action.

=head2 $self->const($tag)

=head2 $self->container($tag)

Contains the container tag to use.
Defaults to C<form>.

=head2 $self->constraint( $type, @names )

Returns a L<HTML::Widget::Constraint> object.

=cut

sub constraint {
    my ( $self, $type, @names ) = @_;
    my $not = 0;
    if ( $type =~ /^Not_(\w+)$/i ) {
        $not++;
        $type = $1;
    }
    my $constraint = $self->_instantiate( "HTML::Widget::Constraint::$type",
        { names => \@names } );
    $constraint->not($not);
    push @{ $self->{_constraints} }, $constraint;
    return $constraint;
}

=head2 $self->elem( $type, $name )

=head2 $self->element( $type, $name )

Returns a L<HTML::Widget::Element> object.

=cut

sub element {
    my ( $self, $type, $name ) = @_;
    my $element =
      $self->_instantiate( "HTML::Widget::Element::$type", { name => $name } );
    push @{ $self->{_elements} }, $element;
    return $element;
}

=head2 $self->embed(@widgets)

Embed another widget.
Note that this will change data in the embedded widgets!

=cut

sub embed {
    my ( $self, @widgets ) = @_;
    for my $widget (@widgets) {
        push @{ $self->{_embedded} }, $widget;
        push @{ $self->{_embedded} }, @{ $widget->{_embedded} }
          if $widget->{_embedded};
        push @{ $self->{_constraints} }, @{ $widget->{_constraints} }
          if $widget->{_constraints};
        push @{ $self->{_filters} }, @{ $widget->{_filters} }
          if $widget->{_filters};
        my $sc_id = $self->name . '_' . $widget->name;
        $widget->name($sc_id);
    }
    return $self;
}

=head2 $self->empty_errors(1)

Create spans for errors even when there's no errors.. (For AJAX validation validation)

=head2 $self->enctype($enctype)

Contains the form encoding type.

=head2 $self->filter( $type, @names )

Returns a L<HTML::Widget::Filter> object.

=cut

sub filter {
    my ( $self, $type, @names ) = @_;
    my $filter =
      $self->_instantiate( "HTML::Widget::Filter::$type",
        { names => \@names } );
    $filter->init($self);
    push @{ $self->{_filters} }, $filter;
    return $filter;
}

=head2 $self->id($id)

Contains the widget id.

=head2 $self->indi($indicator)

=head2 $self->indicator($indicator)

Contains the submitted form indicator.

=head2 $self->legend($legend)

Contains the legend name for this widget.

=head2 $self->merge(@widget)

Merge in another widget.

=cut

sub merge {
    my ( $self, @widgets ) = @_;
    for my $widget (@widgets) {
        push @{ $self->{_elements} }, @{ $widget->{_elements} }
          if $widget->{_elements};
        push @{ $self->{_constraints} }, @{ $widget->{_constraints} }
          if $widget->{_constraints};
        push @{ $self->{_filters} }, @{ $widget->{_filters} }
          if $widget->{_filters};
    }
    return $self;
}

=head2 $self->method($method)

Contains the form method.

=head2 $self->result( $query, $uploads )

=head2 $self->process( $query, $uploads )

Returns a L<HTML::Widget::Result> object.

=cut

sub process {
    my ( $self, $query, $uploads ) = @_;

    my $errors = {};
    $query   ||= $self->query;
    $uploads ||= $self->uploads;

    # Some sane defaults
    if ( $self->container eq 'form' ) {
        $self->attributes->{action} ||= '/';
        $self->attributes->{method} ||= 'post';
    }

    for my $element ( @{ $self->{_elements} } ) {
        $element->prepare($self);
        $element->init($self) unless $element->{_initialized};
        $element->{_initialized}++;
    }
    for my $filter ( @{ $self->{_filters} } ) {
        $filter->prepare($self);
        $filter->init($self) unless $filter->{_initialized};
        $filter->{_initialized}++;
    }
    for my $constraint ( @{ $self->{_constraints} } ) {
        $constraint->prepare($self);
        $constraint->init($self) unless $constraint->{_initialized};
        $constraint->{_initialized}++;
    }
    if ( $self->{_embedded} ) {
        for my $embedded ( @{ $self->{_embedded} } ) {
            for my $element ( @{ $embedded->{_elements} } ) {
                $element->prepare($self);
                $element->init($self) unless $element->{_initialized};
                $element->{_initialized}++;
            }
        }
    }

    my @js_callbacks;
    for my $constraint ( @{ $self->{_constraints} } ) {
        push @js_callbacks, sub { $constraint->process_js( $_[0] ) };
    }
    my %params;
    if ($query) {
        die "Invalid query object"
          unless blessed($query)
          and $query->can('param');
        my @params = $query->param;
        for my $param (@params) {
            my $value = $query->param($param);
            $params{$param} = $value;
        }
        for my $filter ( @{ $self->{_filters} } ) {
            $filter->process( \%params, $uploads );
        }
        for my $constraint ( @{ $self->{_constraints} } ) {
            my $results = $constraint->process( $self, \%params, $uploads );
            for my $result ( @{$results} ) {
                my $name  = $result->name;
                my $class = ref $constraint;
                $class =~ s/^HTML::Widget::Constraint:://;
                $class =~ s/::/_/g;
                $result->type($class);
                push @{ $errors->{$name} }, $result;
            }
        }
    }

    return HTML::Widget::Result->new(
        {
            attributes    => $self->attributes,
            container     => $self->container,
            _constraints  => $self->{_constraints},
            _elements     => $self->{_elements},
            _embedded     => $self->{_embedded} || [],
            _errors       => $errors,
            _js_callbacks => \@js_callbacks,
            _params       => \%params,
            legend        => $self->legend,
            subcontainer  => $self->subcontainer,
            strict        => $self->strict,
            empty_errors  => $self->empty_errors,
        }
    );
}

=head2 $self->query($query)

Contains the query object to use for validation input.

=head2 $self->strict($strict)

Only consider parameters that pass at least one constraint valid.

=head2 $self->subcontainer($tag)

Contains the subcontainer tag to use.
Defaults to C<fieldset>.

=head2 $self->uploads($uploads)

Contains a arrayref of L<Apache2::Upload> compatible objects.

=cut

sub _instantiate {
    my ( $self, $class, @args ) = @_;
    eval "require $class";
    die qq/Couldn't to load class "$class", "$@"/ if $@;
    return $class->new(@args);
}

=head1 SEE ALSO

L<Catalyst>

=head1 AUTHOR

Sebastian Riedel, C<sri@oook.de>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;
