my $expected_version = "$ENV{PKG_VERSION}";
print("import: Term::ReadLine\n");
use Term::ReadLine;

if (defined Term::ReadLine::Gnu->VERSION) {
        my $given_version = Term::ReadLine::Gnu->VERSION;
        $given_version =~ s/0+$//;
        die('Expected version ' . $expected_version . ' but found ' . $given_version) unless ($expected_version eq $given_version);
        print(' using version ' . Term::ReadLine::Gnu->VERSION . '
');
};
