#!/usr/bin/perl -w
#
# xen-features.pl	print Linux Xen guest feature bits in human.
#
# This will get out of date. If you're a Xen developer, you are welcome to put
# this under xen/tools/misc, where others can update it.
#
# 16-May-2016	Antoine Ginies
#	display XEN version
#	display XEN capabilities
#	show Disabled feature(s) available in kernel
# 05-May-2014	Brendan Gregg	Created this.

use strict;

sub cat_ {
    open( my $F, $_[0] ) or return;
    my @l = <$F>;
    wantarray() ? @l : join '', @l;
}

open FEAT, "/sys/hypervisor/properties/features" or die "ERROR open(): $!";
my $features = <FEAT>;
close FEAT;
chomp $features;
my $decfeatures = hex $features;

my $VERSIONDIR = "/sys/hypervisor/version/";
my @files = ( "major", "minor", "extra" );
my $version;
foreach my $f (@files) {
    foreach ( cat_("$VERSIONDIR/$f") ) {
        chomp($_);

        # add missing . between major and minor
        if ( $f =~ /major/ ) { $_ = $_ . "." }
        $version = $version . $_;
    }
}

my $capa = cat_("/sys/hypervisor/properties/capabilities");

print "Xen version: $version \n";
print "Xen capabilities: $capa \n";
print "Xen features: $features\n";

foreach (<DATA>) {
    my ( $def, $feat, $bit ) = split;
    $feat =~ s/^XENFEAT_//;
    if ( $decfeatures & ( 1 << $bit ) ) {
        print "+ ENABLED: $feat\n";
    }
    else {
        print "-Disable: $feat\n";
    }
}

print
"\nhttp://xenbits.xen.org/docs/unstable-staging/hypercall/x86_64/include,public,features.h.html\n";

# The following are from include/xen/interface/features.h, and will need updating:

__DATA__
#define XENFEAT_writable_page_tables       0
#define XENFEAT_writable_descriptor_tables 1
#define XENFEAT_auto_translated_physmap    2
#define XENFEAT_supervisor_mode_kernel     3
#define XENFEAT_pae_pgdir_above_4gb        4
#define XENFEAT_mmu_pt_update_preserve_ad  5
#define XENFEAT_hvm_callback_vector        8
#define XENFEAT_hvm_safe_pvclock           9
#define XENFEAT_hvm_pirqs           10
#define XENFEAT_dom0                      11
