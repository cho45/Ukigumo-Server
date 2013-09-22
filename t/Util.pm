package t::Util;
BEGIN {
    unless ($ENV{PLACK_ENV}) {
        $ENV{PLACK_ENV} = 'test';
    }
}
use parent qw/Exporter/;
use Test::More 0.98;
use Ukigumo::Server;

our @EXPORT = qw//;

{
    # utf8 hack.
    binmode Test::More->builder->$_, ":utf8" for qw/output failure_output todo_output/;
    no warnings 'redefine';
    my $code = \&Test::Builder::child;
    *Test::Builder::child = sub {
        my $builder = $code->(@_);
        binmode $builder->output,         ":utf8";
        binmode $builder->failure_output, ":utf8";
        binmode $builder->todo_output,    ":utf8";
        return $builder;
    };
}

{
    my $c = Ukigumo::Server->new;
    $c->setup_schema();
    $c->dbh->do(q{DELETE FROM report});
    $c->dbh->do(q{DELETE FROM branch});
}

package t::Util::Guard;

sub new {bless {}, shift};
sub DESTROY {
    unlink 'test.db';
}

1;
