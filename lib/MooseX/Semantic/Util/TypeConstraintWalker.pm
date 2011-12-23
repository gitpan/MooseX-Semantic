package MooseX::Semantic::Util::TypeConstraintWalker;
use Moose::Role;
use Try::Tiny;
use Data::Dumper;
use MooseX::Semantic::Types qw(UriStr);
use feature qw(switch);

sub _find_parent_type {
    my ($self, $attr_or_type_constraint, $needle, %opts) = @_;
    return unless $attr_or_type_constraint;

    $opts{match_all} //= 1;
    $opts{match_any} //= 1;

    my ($attr, $attr_name, $type_constraint);
    my $type_ref = ref $attr_or_type_constraint;

    if (ref $needle && ref ($needle) eq 'ARRAY') {
        my $needles_searched_size = scalar @{$needle};
        my @needles_matched = grep {$self->_find_parent_type($attr_or_type_constraint, $_, %opts)} @{$needle};
        if ($opts{match_any}) {
            return @needles_matched;
        }
        if ($opts{match_all}){
            return $needles_searched_size == scalar @needles_matched;
        }
        # TODO
        # return @needles_matched;
    }

    if ( ! ref $attr_or_type_constraint ) {
        return unless $self->meta->has_attribute($attr_or_type_constraint);
        $type_constraint = $self->meta->get_attribute($attr_or_type_constraint)->type_constraint;
    }
    elsif ($type_ref =~ m'^Moose::Meta::(?:Attribute|Class)') {
        $type_constraint = $attr_or_type_constraint->type_constraint;
    }
    elsif ($type_ref =~ m'^Moose::Meta::TypeConstraint') {
        $type_constraint = $attr_or_type_constraint;
    }
    else {
        # warn ref $attr_or_type_constraint;
        # warn $attr_or_type_constraint;
        return;
    }
    if ($opts{look_vertically}) {
        if ($type_constraint->can('type_parameter') && $type_constraint->type_parameter) {
            $type_constraint = $type_constraint->type_parameter;
        }
    }
    return $self->_find_parent_type_for_type_constraint( $type_constraint, $needle, %opts );
}

sub _find_parent_type_for_type_constraint {
    my ($self, $type_constraint, $needle, %opts) = @_;
    $opts{max_depth} = 9999 unless defined $opts{max_depth};
    $opts{max_width} = 9999 unless defined $opts{max_width};
    $opts{current_depth} = 0 unless $opts{current_depth};
    $opts{current_width} = 0 unless $opts{current_width};
    # warn Dumper $type_constraint->name;
    # warn Dumper \%opts;
    # warn Dumper $opts{current_depth};

    if (   ( $opts{current_depth} > $opts{max_depth} )
        || ( $opts{current_width} > $opts{max_width} ) )
    {
        return;
    }
    $opts{current_depth}++;

    my $type_name = $type_constraint->name;
    if ($opts{look_vertically} && $type_constraint->can('type_parameter') && $type_constraint->type_parameter) {
        $opts{current_width}++;
        return $self->_find_parent_type_for_type_constraint( $type_constraint->type_parameter, $needle, %opts );
    }
    if (ref $needle && ref ($needle) eq 'CODE'){
        if ($type_name->can('does') && $needle->( $type_constraint->name )) {
            return $type_constraint->name 
        }
    }
    elsif ($type_constraint->name eq $needle) {
        return $needle;
    }
    if ($type_constraint->has_parent) {
        return $self->_find_parent_type_for_type_constraint($type_constraint->parent, $needle, %opts );
    }
    else {
        return;
    }
}

sub _walk_attributes{
    my ($self, $cb_opts, $cb_selector) = @_;
    my $cb;
    for (qw(before literal resource literal_in_array resource_in_array)) { 
        $cb->{$_} = defined $cb_opts->{$_} ? $cb_opts->{$_} : sub {}
    }
    ATTR:
    for my $attr_name ($self->meta->get_attribute_list) {
        my $attr = $self->meta->get_attribute($attr_name);
        next unless ($attr->does('MooseX::Semantic::Meta::Attribute::Trait'));
        my $attr_type = $attr->type_constraint;

        my $stash = {};
        $stash->{uris}  = [$attr->uri] if $attr->has_uri;
        $stash->{attr_val} = $self->$attr_name if blessed $self;

        if ($cb_opts->{'schema'}){
            $cb_opts->{'schema'}->( $attr );
            next ATTR;
        }

        # XXX
        # skip this attribute if the 'before' callback returns a true value
        next if $cb->{before}->($attr, $stash, @_);
        my $callback_name;
        if ( ! $attr_type
            || $attr_type eq 'Str'
            || $self->_find_parent_type( $attr_type, 'Num' )
            || $self->_find_parent_type( $attr_type, 'Bool' ))
        {
            $callback_name = 'literal';
        }
        elsif ($self->_find_parent_type($attr->type_constraint, 'Object')
            || $self->_find_parent_type($attr->type_constraint, 'ClassName'))
        {
            $callback_name = 'resource';
        }
        elsif ($self->_find_parent_type($attr->type_constraint, 'ArrayRef')) {
            if ( ! $attr_type->can('type_parameter')
                || $attr_type->type_parameter eq 'Str'
                || $self->_find_parent_type( $attr_type->type_parameter, 'Num' )
                || $self->_find_parent_type( $attr_type->type_parameter, 'Bool' ))
            {
                $callback_name = 'literal_in_array';
            }
            elsif ( $self->_find_parent_type( $attr_type->type_parameter, 'Object' ) 
                || $self->_find_parent_type( $attr_type->type_parameter, 'ClassName' ) ) {
                $callback_name = 'resource_in_array';
            }
        }
        $cb->{$callback_name}->($attr, $stash, @_);
    }
}

sub _get_hash_keys_for_attr {
    my $self = shift;
    my ($attr, %opts) = @_;
    $opts{hash_key} //= 'Moose';
    my @keys;
    if ($opts{hash_key} =~ 'RDF') {
        push (@keys, $attr->uri) if $attr->has_uri;
        push (@keys, @{$attr->uri_writer}) if $attr->has_uri_writer;
    }
    if ($opts{hash_key} =~ 'Moose') {
        push @keys, $attr->name;
    }
    unless (scalar @keys) {
        die "Bad value for hash_key $opts{hash_key}";
    }
    return [ map { UriStr->coerce($_) } @keys];
}

sub _attr_to_hash {
    my $self = shift;
    my ($hash, $attr, $val, %opts ) = @_;
    my $keys_aref = $self->_get_hash_keys_for_attr($attr, %opts) ;
    # warn Dumper $keys_aref;
    my @keys = @{ $keys_aref };
    for (@keys) {
        $hash->{$_} = $val;
    }
    return 1;
}

1;
