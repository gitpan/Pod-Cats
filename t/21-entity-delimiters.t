#!/usr/bin/perl

use strict;
use warnings;

my $pc = Pod::Cats::Test->new({
    delimiters => '[]|'
});
chomp(my @lines = <DATA>);
$pc->parse_lines(@lines);

package Pod::Cats::Test;

use 5.010;
use Data::Dumper;
use Test::More 'no_plan';

use parent 'Pod::Cats';

sub handle_entity {
    my $self = shift;
    
    my $entity = shift;
    my $content = shift;

    given ($entity) {
        when('B') {
            is($content, 'brackets', 'B[] entity discovered' );
        }
        when('C') {
            fail( 'C<> should not have been parsed.' );
        }
        when('P') {
            is($content, 'pipes', 'P|| entity discovered');
        }
        when('T') {
            is($content, ' Two|pipes ', 'T|| || used two pipes!');
        }
        default {
            fail(Dumper [$entity, $content]);
        }
    }
    return $content;
}

1;

package main;

__DATA__
This paragraph uses B[brackets] instead of C<chevrons>

This paragraph uses P|pipes| as delimiters.

This paragraph uses T|| Two|pipes ||!
