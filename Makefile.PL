use ExtUtils::MakeMaker;

WriteMakefile(
    NAME          => 'TouhouMyArrange',
    AUTHOR        => 'Some Person <person@example.com>',
    VERSION_FROM  => 'lib/TouhouMyArrange.pm',
    PREREQ_PM     => {
        'Amon2'                           => '3.27',
        'Text::Xslate'                    => '1.5006',
        'Test::More'                      => '0.98',
    },
    MIN_PERL_VERSION => '5.008001',
    (-d 'xt' and $ENV{AUTOMATED_TESTING} || $ENV{RELEASE_TESTING}) ? (
        test => {
            TESTS => 't/*.t xt/*.t',
        },
    ) : (),
);
