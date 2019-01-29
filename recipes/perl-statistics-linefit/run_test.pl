#  tests for perl-statistics-linefit-0.07-pl526_0 (this is a generated file);
print('===== testing package: perl-statistics-linefit-0.07-pl526_0 =====');
print('running run_test.pl');
#  --- run_test.pl (begin) ---
my $expected_version = "0.06";
print("import: Statistics::LineFit\n");
use Statistics::LineFit;

if (defined Statistics::LineFit->VERSION) {
	my $given_version = Statistics::LineFit->VERSION;
	$given_version =~ s/0+$//;
	die('Expected version ' . $expected_version . ' but found ' . $given_version) unless ($expected_version eq $given_version);
	print('	using version ' . Statistics::LineFit->VERSION . '
');

}

print('===== perl-statistics-linefit-0.07-pl526_0 OK =====');
