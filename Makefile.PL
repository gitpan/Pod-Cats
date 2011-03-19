use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Pod::Cats',
    AUTHOR              => q{Altreus <altreus@perl.org>},
    VERSION_FROM        => 'lib/Pod/Cats.pm',
    ABSTRACT_FROM       => 'lib/Pod/Cats.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
        'Parser::MGC' => 0.06,
        'List::Util' => 1.21,
        'Carp'      => 1.11,
        'Data::Dumper' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Pod-Cats-*' },
);
