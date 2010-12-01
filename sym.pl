#!/usr/bin/env perl
# Tool to create relative symlinks.
#
# (c) 2010 <grawity@gmail.com>
# Released under WTFPL v2 <http://sam.zoy.org/wtfpl/>

use warnings;
use strict;

use Getopt::Long qw(:config bundling no_ignore_case);
use File::Basename;
use File::Spec;

my $force = 0;
my $dest;

sub usage {
	my $me = basename($0);
	print STDERR "usage: $me [-f] TARGET LINKNAME\n";
	print STDERR "       $me [-f] TARGET... DIRECTORY\n";
	exit 2;
}

sub do_link {
	my ($target, $link) = @_;
	print "$target -> $link\n";
	if (-e $link) {
		if ($force) {
			warn "$link already exists - replacing\n";
			unlink($link);
			symlink($target, $link);
		} else {
			warn "$link already exists - skipping\n";
		}
	} else {
		symlink($target, $link);
	}
}

GetOptions(
	"f|force" => \$force,
	"t|target-directory=s" => \$dest,
) or usage;

if (!defined $dest) {
	if (scalar(@ARGV) > 1) {
		$dest = pop(@ARGV);
	} else {
		$dest = ".";
	}
}

if (!@ARGV) {
	usage;
}

if (-d $dest) {
	# target [target...] dirname
	for my $target (@ARGV) {
		my $target = File::Spec->abs2rel($target, $dest);
		my $link = File::Spec->catfile($dest, basename($target));
		do_link($target, $link);
	}
} elsif (scalar(@ARGV) > 1) {
	# target target... name
	die "error: target is not a directory\n";
} else {
	# target name
	my $target = pop(@ARGV);
	my $target = File::Spec->abs2rel($target, dirname($dest));
	do_link($target, $dest);
}
