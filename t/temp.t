use Test::More skip_all => 'Need to write actual tests'; 
use common::sense;
use Data::Dumper;
use Carp;

sub hash_array_keys { 
    my %hash;
    my @keys = qw(a b c);
    my @vals = qw(X Y Z);
    @hash{@keys} = @vals;
    warn Dumper \%hash;
    warn Dumper ("-") x 10;
}
# &hash_array_keys;

sub by_ref{
    my ($ref) = @_;
    $ref->{a} = 'b';
}
my $x = {};
&by_ref( $x );
print $x->{a};

1;
